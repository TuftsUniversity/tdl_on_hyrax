# frozen_string_literal: true
class ImageviewerController < CatalogController
  layout "bookviewer"

  def show_book
    parent = params[:parent]
    obj = ActiveFedora::Base.find(parent, cast: true)
    published = true
    published = !obj.state.id.to_s.include?('inactive') unless obj.state.nil?
    displays = obj.displays_in.include? "dl"
    redirect_to "/concern/pdfs/#{params[:parent]}" unless published && displays
    ""
  end
end
