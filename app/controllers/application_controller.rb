# frozen_string_literal: true
class ApplicationController < ActionController::Base
  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render text: exception, status: 500
  end

  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Hydra::Controller::ControllerBehavior

  # Adds Hyrax behaviors into the application controller
  include Hyrax::Controller
  include Hyrax::ThemedLayoutController
  with_themed_layout '1_column'

  protect_from_forgery with: :exception

  # Since we only expect to ever use English, set the locale to :en
  # without having it passed in via the URL. Then, ensure locale: I18n.locale
  # is not set in default_url_options
  before_action :set_locale

  # Fixing annoying DEPRECATION WARNING: discard_flash_if_xhr is deprecated spam
  skip_after_action :discard_flash_if_xhr

  # grabbd this code from https://github.com/pulibrary/figgy/blob/b62011b8d64efa4ae08a3d149b08e8fe16adf7ff/app/controllers/application_controller.rb#L25

  # TDL has no use cases for having unique shared searches, and this prevents
  # the user list from growing out of control.
  #
  def guest_user
    @guest_user ||= User.where(guest: true).first || super
  end

  def guest_uid_authentication_key(key)
    key &&= nil unless /^guest/.match?(key.to_s)
    return key if key
    "guest_" + guest_user_unique_suffix
  end

  def set_locale
    I18n.locale = :en
  end

  def default_url_options
    super.except(:locale)
  end

  def robots
    render 'sites/robots.txt.erb'
  end

  ##
  # For use in index fields. Checks if creator is in the solr doc.
  #
  # @param {hash} document
  #   The solr document.
  #
  # @return {bool}
  #   If creator is in the doc or not.
  def no_creator?(_, document)
    document._source['creator_tesim'].nil?
  end

  ##
  # For use in index fields. Checks if primary_date is in the solr doc.
  #
  # @param {hash} document
  #   The solr document.
  #
  # @return {bool}
  #   If primary_date is in the doc or not.
  def no_primary_date?(_, document)
    document._source['primary_date_tesim'].nil?
  end
end
