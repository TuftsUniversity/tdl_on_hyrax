# Generated via
#  `rails generate hyrax:work Tei`

module Hyrax
  class TeisController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Tei
    self.show_presenter = Hyrax::TeiPresenter
  end
end
