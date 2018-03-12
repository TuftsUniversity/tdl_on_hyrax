module Hyrax
  class AudiosController < CatalogController
    helper :transcripts
    include Hyrax::WorksControllerBehavior
    include WithTranscripts
    self.curation_concern_type = ::Audio
    self.show_presenter = Hyrax::AudioPresenter

    before_action :load_fedora_document


    def audio_transcriptonly
      respond_to do |wants|
        wants.html { presenter && parent_presenter }
      end
    end
  end
end
