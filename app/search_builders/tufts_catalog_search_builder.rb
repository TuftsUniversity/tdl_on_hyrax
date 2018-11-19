class TuftsCatalogSearchBuilder < Hyrax::CatalogSearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightAdvancedSearch::AdvancedSearchBuilder
  self.default_processor_chain += [:add_advanced_parse_q_to_solr, :add_advanced_search_to_solr, :show_only_active_records]
  # Add a filter query to restrict the search to documents the current user has access to
  include Hydra::AccessControlsEnforcement
  include Hyrax::SearchFilters
  # Override default behavior so admin users can see unpublished works in the search results
  def show_only_active_records(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << '-suppressed_bsi:true'
    solr_parameters[:fq] << '-embargo_release_date_dtsi:[NOW TO *]'
    solr_parameters[:fq] << '-embargo_note_tesim:*'
  end
end

