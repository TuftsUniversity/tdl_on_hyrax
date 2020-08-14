module Tufts
  class ImageCacheClearer
    def self.delete_image_cache(image_id)
      unless Image.exists?(image_id)
        Rails.logger.info "Couldn't find image #{image_id}"
        return
      end

      Image.find(image_id).file_sets.each do |fs|
        delete_riiif_cache(fs.id)
        delete_rails_cache(fs.id)
      end
    rescue
      Rails.logger.error "RESCUE: Couldn't find image: #{image_id}"
    end

    def self.delete_riiif_cache(file_set_id)
      riiif_files = Dir["#{riiif_cache_path}/#{file_set_id}-*"]
      if riiif_files.any?
        riiif_files.each do |f|
          Rails.logger.info "Deleting RIIIF file: #{f}."
          File.delete(f)
        end
      else
        Rails.logger.info "Found no Riiif cache for #{file_set_id}"
      end
    end

    def self.delete_rails_cache(file_set_id)
      Riiif::Image.cache.delete_matched(/riiif:#{file_set_id}:.*/)
    end

    def self.riiif_cache_path
      @riiif_cache_path ||= Riiif::Image.file_resolver.cache_path
    end
  end
end
