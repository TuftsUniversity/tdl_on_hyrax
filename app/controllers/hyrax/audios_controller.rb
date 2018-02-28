# Generated via
#  `rails generate hyrax:work Audio`

module Hyrax
  class AudiosController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Audio
    self.show_presenter = Hyrax::AudioPresenter
  end
end
