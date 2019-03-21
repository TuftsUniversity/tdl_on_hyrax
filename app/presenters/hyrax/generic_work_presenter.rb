module Hyrax
  class GenericWorkPresenter < Hyrax::WorkShowPresenter
    Tufts::Terms.shared_terms.each { |term| delegate term, to: :solr_document }

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

    def is_part_of
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

    def source
      solr_document[:source_tesim]
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

    def corporate_name
      solr_document[:corporate_name_tesim]
    end

    def geog_name
      solr_document[:geog_name_tesim]
    end

    def bibliographic_citation
      solr_document[:bibliographic_citation_tesim]
    end
  end
end
