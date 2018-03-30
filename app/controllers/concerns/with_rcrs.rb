module WithRcrs
  extend ActiveSupport::Concern
  included do
    # Use params[:id] to load an object from Fedora.
    # Sets @document_fedora with the loaded object.
    # Sets @document_rcr with the RCR (EAC) file_set content of the loaded object.
    def load_fedora_document
      return unless params[:id].present?

      @document_fedora = ActiveFedora::Base.find(params[:id])
      @document_rcr = nil

      return unless @document_fedora.instance_of?(Rcr)

      file_sets = @document_fedora.file_sets
      unless file_sets.nil? || file_sets.empty?
        file_set = file_sets.first
        original_file = file_set.original_file
        unless original_file.nil?
          original_content = original_file.content
          unless original_content.nil?
            @document_rcr = Datastreams::Rcr.from_xml(original_content)
          end
        end
      end
    end
  end
end
