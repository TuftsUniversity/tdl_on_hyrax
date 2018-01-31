# Generated via
#  `rails generate hyrax:work Image`

module Hyrax
  class ImagesController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Image
    self.show_presenter = Hyrax::ImagePresenter
  end
end
