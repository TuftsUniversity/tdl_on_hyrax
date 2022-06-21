# frozen_string_literal: true
module WithTeis
  extend ActiveSupport::Concern
  included do
    # Use params[:id] to load an object from Fedora.
    # Sets @document_fedora with the loaded object.
    # Sets @document_ead with the EAD file_set content of the loaded object.
    # rubocop:disable Metrics/CyclomaticComplexity
    def load_fedora_document
      return if params[:id].blank?

      return if ["73666f980", "5712mj551", "qv33s7092", "3197xx41j", "057423334", "d217r103f", "5t34sv62t"].include? params[:id]

      @document_fedora = ActiveFedora::Base.find(params[:id])
      @document_tei = nil

      return unless @document_fedora.instance_of?(Tei)
      return if @document_fedora.file_sets.nil? || @document_fedora.file_sets.first.nil? || @document_fedora.file_sets.first.original_file.nil?

      @document_tei = Nokogiri::XML(@document_fedora.file_sets.first.original_file.content)
      @document_tei&.remove_namespaces!
    end
  end
end
