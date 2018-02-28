# Generated via
#  `rails generate hyrax:work Video`

module Hyrax
  class VideosController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Video
    self.show_presenter = Hyrax::VideoPresenter
  end
end
