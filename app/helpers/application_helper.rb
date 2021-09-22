# frozen_string_literal: true
module ApplicationHelper
  ##
  # A banner image from app/assets/images/banners, chosen at random
  #
  # @return {str}
  #   A string, 'banners/***', for use in image_tag()
  def random_banner
    banners = Dir[Rails.root.join('app', 'assets', 'images', 'banners', '*')]
    "banners/#{File.basename(banners.sample, '.*')}"
  end
end
