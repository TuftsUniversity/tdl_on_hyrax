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

    # sitemap generator
    config.sitemap = {
      generate: true
    }

    # Used in eads_helper.rb to add a link to <userestrict> elements.
    config.use_restrict_text_match = 'Reproductions and Use'
    config.use_restrict_text_replace = '<a href="https://sites.tufts.edu/dca/about-us/research-help/reproductions-and-use/">Reproductions and Use</a>'

    # Used in feedback_mailer.rb
    config.tdl_feedback_address = "dl_feedback@elist.tufts.edu"
    config.tdl_feedback_subject = "TDL Content Feedback"
    config.tdl_contact_address = "dl_feedback@elist.tufts.edu"
    config.tdl_contact_subject = "Contact DCA"
  end
end
