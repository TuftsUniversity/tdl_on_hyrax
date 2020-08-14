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

# Patching HTTPFileResolver to namespace cached images with their FileSet ids.
module Riiif
  class HTTPFileResolver
    def find(id)
      remote = RemoteFile.new(uri(id),
                              cache_path: cache_path,
                              basic_auth_credentials: basic_auth_credentials,
                              fs_id: id.split('/').first)
      Riiif::File.new(remote.fetch)
    end

    class RemoteFile
      private

        def file_name
          fs_id = @options.fetch(:fs_id)
          url_hash = Digest::MD5.hexdigest(url)

          full_name = fs_id.present? ? "#{fs_id}-#{url_hash}" : url_hash
          @cache_file_name ||= ::File.join(cache_path, full_name + ext.to_s)
        end
    end
  end

  class Image
    def cache_key(id, options)
      str = options.to_h.merge(id: id)
              .delete_if { |_, v| v.nil? }
              .sort_by { |k, _v| k.to_s }
              .to_s

      # Use a MD5 digest to ensure the keys aren't too long, and a prefix
      # to avoid collisions with other components in shared cache.
      'riiif:' + id.split('/').first + ':' + Digest::MD5.hexdigest(str)
    end
  end
end
