# frozen_string_literal: true
class SearchBuilder < Hyrax::CatalogSearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightRangeLimit::RangeLimitBuilder
  # Add a filter query to restrict the search to documents the current user has access to
  #  include Hydra::AccessControlsEnforcement
  #  include Hyrax::SearchFilters
  include BlacklightAdvancedSearch::AdvancedSearchBuilder
  self.default_processor_chain += [:add_advanced_parse_q_to_solr, :add_advanced_search_to_solr, :add_dl_filter, :suppress_embargo_records, :supress_eads_conditionally]

  def supress_eads_conditionally(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << '-has_model_ssim:Ead' if @scope.request.env["PATH_INFO"].include?("/filtered_catalog")
  end

  def add_dl_filter(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << 'displays_in_sim:dl'
  end

  # Override default behavior so admin users can see unpublished works in the search results
  def suppress_embargo_records(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << '-suppressed_bsi:true'
    solr_parameters[:fq] << '-embargo_release_date_dtsi:[NOW TO *]'
  end

  ##
  # @example Adding a new step to the processor chain
  #   self.default_processor_chain += [:add_custom_data_to_query]
  #
  #   def add_custom_data_to_query(solr_parameters)
  #     solr_parameters[:custom] = blacklight_params[:user_value]
  #   end
end
