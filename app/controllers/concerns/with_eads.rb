# frozen_string_literal: true
module WithEads
  extend ActiveSupport::Concern
  included do
    # Use params[:id] to load an object from Fedora.
    # Sets @document_fedora with the loaded object.
    # Sets @document_ead with the EAD file_set content of the loaded object.
    def load_fedora_document
      return if params[:id].blank?

      @document_fedora = ActiveFedora::Base.find(params[:id])
      @document_ead = nil

      return unless @document_fedora.instance_of?(Ead)
      return if @document_fedora.file_sets.nil? || @document_fedora.file_sets.first.nil? || @document_fedora.file_sets.first.original_file.nil?

      @document_ead = Datastreams::Ead.from_xml(@document_fedora.file_sets.first.original_file.content)
      @document_ead.ng_xml.remove_namespaces! unless @document_ead.nil? # rubocop:disable Style/SafeNavigation
    end
  end
end
