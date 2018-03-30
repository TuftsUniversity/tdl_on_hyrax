# Generated via
#  `rails generate hyrax:work Rcr`
module Hyrax
  class RcrPresenter < GenericWorkPresenter
    def rcr_id
      fsps = file_set_presenters

      return if fsps.nil?

      fsps.each do |fsp|
        return fsp.id if fsp.mime_type == "text/xml"
      end
    end
  end
end
