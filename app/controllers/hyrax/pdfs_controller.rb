# frozen_string_literal: true
module Hyrax
  class PdfsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include WithShowEnforcement

    before_action :enforce_show_permissions, only: :show

    self.curation_concern_type = ::Pdf
    self.show_presenter = Hyrax::PdfPresenter
  end
end
