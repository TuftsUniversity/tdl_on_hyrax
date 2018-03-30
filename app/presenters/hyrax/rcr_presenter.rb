# Generated via
#  `rails generate hyrax:work Rcr`
module Hyrax
  class RcrPresenter < GenericWorkPresenter

    def rcr_id
      fsps = file_set_presenters

      return if fsps.nil?

      fsps.each do |fsp|
        if fsp.mime_type == "text/xml"
          return fsp.id
        end
      end
    end

  end
end
