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

  ##
  # Generates a item_referral parameter for the contact link, if user is on a item page.
  #
  # @param {str} controller
  #   Controller name
  # @param {str} action
  #   Action name
  #
  # @return {str}
  def contact_with_url(controller, action)
    return '' unless ['audios', 'eads', 'images', 'pdfs', 'rcrs', 'teis', 'videos'].include?(controller)
    return '' unless action == 'show'
    "?item_referral=#{CGI.escape(request.env['PATH_INFO'])}"
  end
end
