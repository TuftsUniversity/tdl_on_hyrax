# frozen_string_literal: true
class SearchBuilder < Hyrax::CatalogSearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightRangeLimit::RangeLimitBuilder
  # Add a filter query to restrict the search to documents the current user has access to
  #  include Hydra::AccessControlsEnforcement
  #  include Hyrax::SearchFilters
  include BlacklightAdvancedSearch::AdvancedSearchBuilder
  # rubocop:disable Metrics/LineLength
  self.default_processor_chain += [:add_advanced_parse_q_to_solr, :add_advanced_search_to_solr, :add_dl_filter, :suppress_embargo_records, :supress_eads_conditionally, :show_works_or_works_that_contain_files]

  def supress_eads_conditionally(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << '-has_model_ssim:Ead' if @scope.request.env["PATH_INFO"].include?("/filtered_catalog")
  end

  def add_dl_filter(solr_parameters)
    solr_parameters[:fq] ||= []
    # solr_parameters[:fq] << 'displays_in_sim:dl'
    # DO NOT CHECK IN PART OF COLLECTIONS
    solr_parameters[:fq] << if Rails.env != "production"
                              'displays_in_sim:dl OR (has_model_ssim:Collection)'
                            else
                              'displays_in_sim:dl'
                            end
  end

  # Override default behavior so admin users can see unpublished works in the search results
  def suppress_embargo_records(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << '-suppressed_bsi:true'
    solr_parameters[:fq] << '-embargo_release_date_dtsi:[NOW TO *]'
  end

  def show_works_or_works_that_contain_files(solr_parameters)
    return if blacklight_params[:q].blank? || blacklight_params[:search_field] != 'all_fields'
    solr_parameters[:user_query] = blacklight_params[:q]
    solr_parameters[:q] = new_query
  end

  private

    # the {!lucene} gives us the OR syntax
    def new_query
      "{!lucene}#{interal_query(dismax_query)} #{interal_query(join_for_works_from_files)}"
    end

    # the _query_ allows for another parser (aka dismax)
    def interal_query(query_value)
      "_query_:\"#{query_value}\""
    end

    # the {!dismax} causes the query to go against the query fields
    def dismax_query
      "{!dismax v=$user_query}"
    end

    # join from file id to work relationship solrized file_set_ids_ssim
    def join_for_works_from_files
      "{!join from=#{ActiveFedora.id_field} to=file_set_ids_ssim}#{dismax_query}"
    end
end
