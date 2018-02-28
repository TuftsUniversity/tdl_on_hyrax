# Generated via
#  `rails generate hyrax:work VotingRecord`

module Hyrax
  class VotingRecordsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::VotingRecord
    self.show_presenter = Hyrax::VotingRecordPresenter
  end
end
