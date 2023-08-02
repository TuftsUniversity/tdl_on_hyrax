# frozen_string_literal: true
require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TdlOnHyrax
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths << Rails.root.join('lib')
    config.autoload_paths << Rails.root.join('lib', 'tufts')

    # Prevents annoying deprecation message
    config.active_record.sqlite3.represent_boolean_as_integer = true

    # sitemap generator
    config.sitemap = {
      generate: true
    }
  end
end

Rails.application.config.active_record.sqlite3.represent_boolean_as_integer = true
