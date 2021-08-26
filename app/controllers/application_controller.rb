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

  def set_locale
    I18n.locale = :en
  end

  def default_url_options
    super.except(:locale)
  end

  def robots
    render 'sites/robots.txt.erb'
  end
end
