# frozen_string_literal: true
module Hyrax
  class EadsController < CatalogController
    helper :eads
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks

    include WithEads
    include WithShowEnforcement

    before_action :enforce_show_permissions, only: :show

    self.curation_concern_type = ::Ead
    self.show_presenter = Hyrax::EadPresenter

    before_action :load_fedora_document

    def fa_overview
      @id = params[:id]
      # or, to use "id" instead of "@id" in views, do this: render locals: {id:  params[:id]}

      respond_to do |wants|
        wants.html { presenter && parent_presenter }
      end

      render layout: "homepage"
    end

    def fa_series
      @id = params[:id]
      @item_id = params[:item_id]
      # or, to use "id" instead of "@id" in views, do this: render locals: {id:  params[:id], item_id: params[:item_id]}

      respond_to do |wants|
        wants.html { presenter && parent_presenter }
      end

      render layout: "homepage"
    end
  end
end
