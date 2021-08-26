# frozen_string_literal: true
module Hyrax
  class VotingRecordsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include WithShowEnforcement

    before_action :enforce_show_permissions, only: :show

    self.curation_concern_type = ::VotingRecord
    self.show_presenter = Hyrax::VotingRecordPresenter
  end
end
