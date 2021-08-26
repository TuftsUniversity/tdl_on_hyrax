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
        original_file = file_set.original_file
        next if original_file.nil?
        next unless original_file.mime_type == "text/xml" || original_file.mime_type == "text/plain"
        if original_file.mime_type == "text/xml"
          @document_tei = Datastreams::Tei.from_xml(original_file.content)
          @document_tei&.ng_xml&.remove_namespaces!
        elsif original_file.mime_type == "text/plain"
          @has_srt = true
          @srt_id = file_set.id
        end
        break
      end
    end
  end
end
