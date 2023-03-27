# frozen_string_literal: true
module Hyrax
  class AudioPresenter < GenericWorkPresenter
    # rubocop:disable Style/RedundantReturn
    def transcript_id
      fsps = file_set_presenters

      return "" if fsps.nil?

      fsps.each do |fsp|
        return fsp.id if fsp.mime_type == "text/xml"
      end

      return ""
    end

    # rubocop:disable Style/RedundantReturn
    def media_id
      fsps = file_set_presenters

      return "" if fsps.nil?

      fsps.each do |fsp|
        next if fsp.mime_type == "text/xml"
        derivative_paths = Hyrax::DerivativePath.derivatives_for_reference(fsp.id)
        derivative_paths.each do |derivative_path|
          return fsp.id if derivative_path.end_with?("mp3")
        end
      end

      return ""
    end
  end
end
