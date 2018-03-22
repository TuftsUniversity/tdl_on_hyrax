# frozen_string_literal: true
class SolrDocument
  include Blacklight::Solr::Document
  include BlacklightOaiProvider::SolrDocumentBehavior

  include Blacklight::Gallery::OpenseadragonSolrDocument

  # Adds Hyrax behaviors to the SolrDocument.
  include Hyrax::SolrDocumentBehavior

  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  # Do content negotiation for AF models.

  use_extension(Hydra::ContentNegotiation)

  field_semantics.merge!(
    identifier: 'id',
    title: 'title_tesim',
    creator: 'creator_tesim',
    subject: ['subject_tesim', 'personal_name_tesim', 'geographic_name_tesim', 'corporate_name_tesim'],
    description: 'description_tesim',
    publisher: 'publisher_tesim',
    date: 'primary_date_tesim',
    type: 'human_readable_type_tesim',
    format: 'format_label_tesim',
    relation: 'is_part_of_tesim',
    rights: 'rights_note_tesim'
  )
end
