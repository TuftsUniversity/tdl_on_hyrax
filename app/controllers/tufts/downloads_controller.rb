# @file
# This is a controller that allows people to download the IIIF derivative images.
# Related issue: https://github.com/curationexperts/riiif/issues/122

module Tufts
  class DownloadsController < ApplicationController
    ##
    # This is nearly the same as Riiif::ImageController#show, but it
    # changes content disposition to attachment, to download the file.
    def download
      begin
        image = Riiif::Image.new(params[:id])
        status = check_status(image)
      rescue Riiif::ImageNotFoundError
        status = :not_found
      end

      data = image.render(iiif_settings)
      send_data data,
                status: status,
                type: 'image/jpeg',
                disposition: "attachment; filename=#{params[:filename]}.jpg"
    end

    private

      ##
      # Checks if the logged in user is authorized to view/download the image.
      # @param {Riiif::Image} image
      #   The image to be authorized.
      # @return
      #   :ok or :unauthorized
      def check_status(image)
        if authorization_service.can?(:show, image)
          :ok
        else
          :unauthorized
        end
      end

      ##
      # Iiif settings for use in the image request.
      def iiif_settings
        {
          region: "full",
          size: "400,",
          rotation: "0",
          quality: "default",
          format: "jpg"
        }
      end

      ##
      # The authorization service for images, as defined in Riiif::Image
      def authorization_service
        Riiif::Image.authorization_service.new(self)
      end
  end
end
