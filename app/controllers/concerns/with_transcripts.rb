# frozen_string_literal: true
module WithTranscripts
  extend ActiveSupport::Concern
  # rubocop:disable Metrics/BlockLength
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
      file_sets = @document_fedora.file_sets
      return if file_sets.nil?

      process_valid_file_sets
    end

    def transcript_embargo?(file_set)
      file_set.embargo && !file_set.embargo.embargo_release_date.nil? ? true : false
    end

    def valid_file_type?(file)
      file.present? && (file.mime_type == 'text/xml' || file.mime_type == 'text/plain')
    end

    def define_file_settings(file, file_set_id)
      if file.mime_type == "text/xml"
        @document_tei = Datastreams::Tei.from_xml(file.content)
        @document_tei&.ng_xml&.remove_namespaces!
      elsif ["text/plain", "text/vtt", "text/srt"].include?(file.mime_type)
        @has_srt = true
        @srt_id = file_set_id
      end
    end

    private

      def process_valid_file_sets
        file_set = @document_fedora.transcript
        return unless file_set
        return if transcript_embargo? file_set
        define_file_settings(file_set.original_file, file_set.id)
      end
  end
  # rubocop:enable Metrics/BlockLength
end
