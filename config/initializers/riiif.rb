Riiif::Image.file_resolver = Riiif::HTTPFileResolver.new

if Rails.env.production?
  Riiif::Image.file_resolver.cache_path = '/tdr/hyrax_iiif/prod'
elsif Rails.env.stage?
  Riiif::Image.file_resolver.cache_path = '/tdr/hyrax_iiif/dev'
end

Riiif::Image.info_service = lambda do |id, _file|
  # id will look like a path to a pcdm:file
  # (e.g. rv042t299%2Ffiles%2F6d71677a-4f80-42f1-ae58-ed1063fd79c7)
  # but we just want the id for the FileSet it's attached to.

  # Capture everything before the first slash
  fs_id = id.sub(/\A([^\/]*)\/.*/, '\1')
  resp = ActiveFedora::SolrService.get("id:#{fs_id}")
  doc = resp['response']['docs'].first
  raise "Unable to find solr document with id:#{fs_id}" unless doc
  { height: doc['height_is'], width: doc['width_is'] }
end

Riiif::Image.file_resolver.id_to_uri = lambda do |id|
  ActiveFedora::Base.id_to_uri(CGI.unescape(id)).tap do |url|
    Rails.logger.info "Riiif resolved #{id} to #{url}"
  end
end

Riiif::Image.authorization_service = Hyrax::IIIFAuthorizationService

FEDORA_CONFIG = YAML.safe_load(File.open(Rails.root.join('config', 'fedora.yml'))).symbolize_keys
conf = FEDORA_CONFIG[Rails.env.to_sym].symbolize_keys

Riiif::Image.file_resolver.basic_auth_credentials = [conf[:user], conf[:password]]

Riiif.not_found_image = Rails.root.join('app', 'assets', 'images', 'us_404.svg')
Riiif.unauthorized_image = Rails.root.join('app', 'assets', 'images', 'us_404.svg')

Riiif::Engine.config.cache_duration_in_days = 365

# Patching a method into HTTPFileResolver that allows us to delete images cached by Riiif.
module Riiif
  class HTTPFileResolver
    def cached_image_location(fs_id)
      file_id = FileSet.find(fs_id).files.first.id
      image_obj = Riiif::Image.new(file_id)
      # Have to run render to get the path out.
      _ = image_obj.render(format: 'jpg')
      image_obj.file.path
    rescue
      ''
    end

    ##
    # Deletes a cached image file.
    # @param {str} id
    #   The FileSet id
    def delete_cached_file(id)
      fail_msg = "Couldn't find file for FileSet: #{id}."
      begin
        file_path = cached_image_location(id)
        if file_path.present? && ::File.exist?(file_path)
          Rails.logger.info("Deleting File: #{file_path} for FileSet: #{id}.")
          ::File.unlink(file_path)
        else
          Rails.logger.info(fail_msg)
        end
      rescue
        Rails.logger.warn(fail_msg)
      end
    end
  end
end
