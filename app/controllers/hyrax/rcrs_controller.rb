module Hyrax
  class RcrsController < CatalogController
    helper :rcrs
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include WithRcrs
    self.curation_concern_type = ::Rcr
    self.show_presenter = Hyrax::RcrPresenter

    before_action :load_fedora_document
  
  end
end
