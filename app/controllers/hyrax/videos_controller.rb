module Hyrax
  class VideosController < CatalogController
    helper :transcripts
    include Hyrax::WorksControllerBehavior
    include WithTranscripts
    self.curation_concern_type = ::Video
    self.show_presenter = Hyrax::VideoPresenter

    before_action :load_fedora_document

    def video_transcriptonly
      respond_to do |wants|
        wants.html { presenter && parent_presenter }
      end

      render layout: "homepage"
    end
  end
end
