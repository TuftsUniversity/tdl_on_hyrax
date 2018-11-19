class TuftsCatalogSearchBuilder < Hyrax::CatalogSearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightAdvancedSearch::AdvancedSearchBuilder
  include BlacklightRangeLimit::RangeLimitBuilder

  self.default_processor_chain += [:add_advanced_parse_q_to_solr, :add_advanced_search_to_solr, :suppress_embargo_records, :add_dl_filter]
  # Add a filter query to restrict the search to documents the current user has access to
  include Hydra::AccessControlsEnforcement
  include Hyrax::SearchFilters

  def add_dl_filter(solr_parameters)
    solr_parameters[:fq] << 'displays_in_sim:dl'
  end

  # Override default behavior so admin users can see unpublished works in the search results
  def suppress_embargo_records(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << '-suppressed_bsi:true'
    solr_parameters[:fq] << '-embargo_release_date_dtsi:[NOW TO *]'
    solr_parameters[:fq] << '-embargo_note_tesim:*'
  end
end
