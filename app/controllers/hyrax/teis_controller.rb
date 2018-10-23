# Generated via
#  `rails generate hyrax:work Tei`

module Hyrax
  class TeisController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include WithTeis
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
  end
end
