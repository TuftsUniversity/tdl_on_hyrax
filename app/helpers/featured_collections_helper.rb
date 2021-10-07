# frozen_string_literal: true

module FeaturedCollectionsHelper
  def featured_blocks
    file = Rails.root.join('config', 'featured_collections.yml').to_s
    YAML.safe_load(File.open(file))&.each(&:deep_symbolize_keys!)
  end
end
