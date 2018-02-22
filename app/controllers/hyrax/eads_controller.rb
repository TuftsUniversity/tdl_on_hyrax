module Hyrax
  class EadsController < CatalogController
    helper :eads
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include WithEads
    self.curation_concern_type = ::Ead
    self.show_presenter = Hyrax::EadPresenter

    before_action :load_fedora_document

    def fa_overview
      @id = params[:id]
      # or, to use "id" instead of "@id" in views, do this: render locals: {id:  params[:id]}
      render layout: "homepage"
    end

    def fa_series
      @id = params[:id]
      @item_id = params[:item_id]
      # or, to use "id" instead of "@id" in views, do this: render locals: {id:  params[:id], item_id: params[:item_id]}
      render layout: "homepage"
    end
  end
end
