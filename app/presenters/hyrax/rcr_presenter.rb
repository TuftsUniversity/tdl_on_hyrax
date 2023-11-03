# frozen_string_literal: true
module Hyrax
  class RcrPresenter < GenericWorkPresenter
    def rcr_id
      fsps = file_set_presenters

      return if fsps.nil?

      fsps.each do |fsp|
        return fsp.id if fsp.mime_type == "text/xml"
      end

      nil
    end
  end
end
