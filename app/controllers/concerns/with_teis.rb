# frozen_string_literal: true
module WithTeis
  extend ActiveSupport::Concern
  included do
    # Use params[:id] to load an object from Fedora.
    # Sets @document_fedora with the loaded object.
    # Sets @document_ead with the EAD file_set content of the loaded object.
    def load_fedora_document
      return if params[:id].blank?

      @document_fedora = ActiveFedora::Base.find(params[:id])
      @document_tei = nil

      return unless @document_fedora.instance_of?(Tei)
      return if @document_fedora.file_sets.nil? || @document_fedora.file_sets.first.nil? || @document_fedora.file_sets.first.original_file.nil?

      @document_tei = Nokogiri::XML(@document_fedora.file_sets.first.original_file.content)
      @document_tei&.remove_namespaces!
    end
  end
end
