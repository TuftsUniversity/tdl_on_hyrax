# Generated via
#  `rails generate hyrax:work GenericObject`

module Hyrax
  class GenericObjectsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include WithShowEnforcement

    before_action :enforce_show_permissions, only: :show

    self.curation_concern_type = ::GenericObject
    self.show_presenter = Hyrax::GenericObjectPresenter
  end
end
