class ImageviewerController < ApplicationController
  layout "pdfviewer"
  def index
    @id = params[:id]
  end
end
