module Tufts
  class ImageCacheClearController < ApplicationController
    skip_before_action :verify_authenticity_token

    def clear_cache
      Rails.logger.info("Request from MIRA recieved to clear cache for FileSet: #{params['id']}")
      Tufts::ImageCacheClearer.delete_file_set_cache(params['id'])
    end
  end
end
