# frozen_string_literal: true
module Hyrax
  class GenericObjectsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include WithShowEnforcement

    before_action :enforce_show_permissions, only: :show

    self.curation_concern_type = ::GenericObject
    self.show_presenter = Hyrax::GenericObjectPresenter
    def advanced
      @id = params[:id]
      # or, to use "id" instead of "@id" in views, do this: render locals: {id:  params[:id]}

      respond_to do |wants|
        wants.html { presenter && parent_presenter }
      end
      render layout: "imageviewer"
    end
  end
end
