# frozen_string_literal: true
module Hyrax
  class GenericWorkPresenter < Hyrax::WorkShowPresenter
    Tufts::Terms.shared_terms.each { |term| delegate term, to: :solr_document }

    def multi_attributes_to_html(fields, options = {})
      field_info = {}

      fields.each do |f|
        unless respond_to?(f)
          Rails.logger.warn("#{self.class} attempted to render #{f}, but no method exists with that name.")
          continue
        end

        values = send(f)
        field_info[f] = values if values.present?
      end

      Tufts::Renderers::MergedAttributeRenderer.new(field_info, options).render
    end

    def date_modified
      return if solr_document[:date_modified_dtsi].nil?
      DateTime.parse(solr_document[:date_modified_dtsi]).in_time_zone.strftime('%F')
    end

    def date_uploaded
      return if solr_document[:date_uploaded_dtsi].nil?
      DateTime.parse(solr_document[:date_uploaded_dtsi]).in_time_zone.strftime('%F')
    end

    def genre
      solr_document[:genre_tesim]
    end

    def temporal
      solr_document[:temporal_tesim]
    end

    def is_part_of # rubocop:disable Naming/PredicateName
      solr_document[:is_part_of_tesim]
    end

    def steward
      solr_document[:steward_tesim]
    end

    def permanent_url
      solr_document[:identifier_tesim]
    end

    def rights_statement
      solr_document[:rights_statement_tesim]
    end

    def member_of_collections
      solr_document[:member_of_collections_ssim]
    end

    def dc_access_rights
      solr_document[:dc_access_rights_tesim]
    end

    def extent
      solr_document[:extent_tesim]
    end

    def source
      solr_document[:source_tesim]
    end

    def doi
      solr_document[:doi_tesim]
    end

    def oclc_number
      solr_document[:oclc_tesim]
    end

    def isbn
      solr_document[:isbn_tesim]
    end

    ##
    # @return [Boolean] true; all works in the app are templatable.
    def work_templatable?
      true
    end

    ## All methods below here are used in manifest.json ##

    def date
      solr_document[:primary_date_tesim] || solr_document[:temporal_tesim] || solr_document[:file_set_date_created_simplified_tesim]
    end

    def type
      solr_document[:has_model_ssim]
    end

    def aspace_cuid
      solr_document[:aspace_cuid_tesim]
    end

    def legacy_pid
      solr_document[:legacy_pid_tesim]
    end

    def corporate_name
      solr_document[:corporate_name_tesim]
    end

    def geog_name
      solr_document[:geog_name_tesim]
    end

    def personal_name
      solr_document[:personal_name_tesim]
    end

    def bibliographic_citation
      solr_document[:bibliographic_citation_tesim]
    end
  end
end
