# frozen_string_literal: true
module Hyrax
  class RcrsController < CatalogController
    helper :rcrs
    include Hyrax::WorksControllerBehavior
    include WithRcrs
    include WithShowEnforcement

    before_action :enforce_show_permissions, only: :show

    self.curation_concern_type = ::Rcr
    self.show_presenter = Hyrax::RcrPresenter

    before_action :load_fedora_document
  end
end
