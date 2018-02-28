# Generated via
#  `rails generate hyrax:work GenericObject`

module Hyrax
  class GenericObjectsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::GenericObject
    self.show_presenter = Hyrax::GenericObjectPresenter
  end
end
