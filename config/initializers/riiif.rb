# frozen_string_literal: true
Riiif::Image.file_resolver = Riiif::HTTPFileResolver.new

if Rails.env.production?
  Riiif::Image.file_resolver.cache_path = '/tdr/hyrax_iiif/prod'
elsif Rails.env.stage?
  Riiif::Image.file_resolver.cache_path = '/tdr/hyrax_iiif_dev'
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
                              # verify_mode: OpenSSL::SSL::VERIFY_NONE,
                              ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE,
                              fs_id: id.split('/').first)
      Riiif::File.new(remote.fetch)
    end

    def download_opts
      basic_auth_credentials ? { http_basic_authentication: basic_auth_credentials, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE } : { ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE }
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

  # Namespaces cache keys for removal later.
  class Image
    def self.cache_key(id, options)
      str = options.to_h.merge(id: id)
                   .delete_if { |_, v| v.nil? }
                   .sort_by { |k, _v| k.to_s }
                   .to_s

      # Use a MD5 digest to ensure the keys aren't too long, and a prefix
      # to avoid collisions with other components in shared cache.
      key = 'riiif:' + id.split('/').first + ':' + Digest::MD5.hexdigest(str)
      Rails.logger.info("Caching: #{id} as #{key}.")
      key
    end
  end
end
# app/services/riiif/option_decode
#
require_dependency Riiif::Engine.root.join('app', 'services', 'riiif', 'option_decoder').to_s
module Riiif
  class OptionDecoder
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Lint/AssignmentInCondition
    def decode_region(region)
      # region = region.gsub("-","")
      if region.nil? || region == 'full'
        Riiif::Region::Imagemagick::FullDecoder.new.decode
      elsif md = /^pct:(\d+),(\d+),(\d+),(\d+)$/.match(region)
        Riiif::Region::Imagemagick::PercentageDecoder
          .new(image_info, md[1], md[2], md[3], md[4]).decode
      elsif md = /^(-?\d+),(-?\d+),(\d+),(\d+)$/.match(region)
        x = Integer(md[1])
        y = Integer(md[2])
        x < 0 ? x = 0 : x # rubocop:disable Style/NumericPredicate
        y < 0 ? y = 0 : x # rubocop:disable Style/NumericPredicate

        # Rails.logger.error "region #{x} #{y} #{md[3]} #{md[4]}"
        Riiif::Region::Imagemagick::AbsoluteDecoder.new(x.to_s, y.to_s, md[3], md[4]).decode
      elsif region == 'square'
        Riiif::Region::Imagemagick::SquareDecoder.new(image_info).decode
      else
        raise InvalidAttributeError, "Invalid region: #{region}"
      end
    end
  end
end
