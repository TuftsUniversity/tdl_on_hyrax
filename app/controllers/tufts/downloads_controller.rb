module Tufts
  class DownloadsController < ApplicationController
    def download
      response.headers['Content-Disposition'] = "attachment; filename=hi.jpg"
      response.headers['Content-Type'] = 'image/jpeg'
      response.headers['Content-Transfer-Encoding'] = 'binary'
      response.headers['Content-Description'] = 'File Transfer'

      redirect_to Riiif::Engine.routes.url_helpers.image_url(
        params[:id],
        host: request.base_url, size: "400,"
      )
    end
  end
end
