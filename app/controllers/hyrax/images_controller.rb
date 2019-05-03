# Generated via
#  `rails generate hyrax:work Image`

module Hyrax
  class ImagesController < CatalogController
    include Hyrax::WorksControllerBehavior
    include WithShowEnforcement

    before_action :enforce_show_permissions, only: :show

    self.curation_concern_type = ::Image
    self.show_presenter = Hyrax::ImagePresenter

    ###
    # Adds thumbnails to the IIIF Manifest for images.
    def manifest
      headers['Access-Control-Allow-Origin'] = '*'

      manifest_json = manifest_builder.to_h
      manifest_json['thumbnail'] = { '@id' => thumbnail }
      render json: manifest_json
    end

    def advanced
      @id = params[:id]
      # or, to use "id" instead of "@id" in views, do this: render locals: {id:  params[:id]}

      respond_to do |wants|
        wants.html { presenter && parent_presenter }
      end
      render layout: "imageviewer"
    end

    private

      ###
      # Gets the external thumbnail path of a resource.
      def thumbnail
        thumbnail_path = Hyrax::ThumbnailPathService.call(@presenter).slice(1..-1)
        root_url + thumbnail_path
      end
  end
end
