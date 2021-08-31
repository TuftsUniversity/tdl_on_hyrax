# frozen_string_literal: true
module WithTranscripts
  extend ActiveSupport::Concern
  included do
    # Use params[:id] to load an object from Fedora.
    # Sets @document_fedora with the loaded object.
    # Sets @document_tei with the TEI file_set content of the loaded object.
    def load_fedora_document
      return if params[:id].blank?

      @document_fedora = ActiveFedora::Base.find(params[:id])
      @document_tei = nil
      @has_srt = false
      @srt_id = ""
      return unless @document_fedora.instance_of?(Audio) || @document_fedora.instance_of?(Video)

      file_sets = @document_fedora.file_sets
      return if file_sets.nil?

      file_sets.each do |file_set|
        next unless valid_file_type?(file_set.original_file)
        define_file_settings(file_set.original_file)
        break
      end
    end

    def valid_file_type?(file)
      file.present? && (file.mime_type == 'text/xml' || file.mime_type == 'text/plain')
    end

    def define_file_settings(file)
      if file.mime_type == "text/xml"
        @document_tei = Datastreams::Tei.from_xml(file.content)
        @document_tei&.ng_xml&.remove_namespaces!
      elsif file.mime_type == "text/plain"
        @has_srt = true
        @srt_id = file_set.id
      end
    end
  end
end
