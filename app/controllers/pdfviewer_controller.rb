# frozen_string_literal: true
class PdfviewerController < ApplicationController
  layout "pdfviewer"
  def index
    @id = params[:id]
    @parent = params[:parent]
    obj = ActiveFedora::Base.find(@parent, cast: true)
    published = true
    published = !obj.state.id.to_s.include?('inactive') unless obj.state.nil?
    redirect_to "/concern/pdfs/#{params[:parent]}" unless published
  end
end
