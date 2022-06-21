# frozen_string_literal: true
module Hyrax
  class TeisController < CatalogController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include WithTeis
    include WithShowEnforcement

    before_action :enforce_show_permissions, only: :show

    self.curation_concern_type = ::Tei
    self.show_presenter = Hyrax::TeiPresenter

    # TODO: Refactor this so that we're not loading from fedora
    before_action :load_fedora_document

    def advanced
      @id = params[:id]
      # or, to use "id" instead of "@id" in views, do this: render locals: {id:  params[:id]}

      respond_to do |wants|
        wants.html { presenter && parent_presenter }
      end
      render layout: "hyrax"
    end

    def streets
      @id = params[:id]
      # or, to use "id" instead of "@id" in views, do this: render locals: {id:  params[:id]}

      respond_to do |wants|
        wants.html { presenter && parent_presenter }
      end
      render layout: "hyrax"
    end
  end
end
