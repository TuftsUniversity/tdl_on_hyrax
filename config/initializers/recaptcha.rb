# frozen_string_literal: true
Recaptcha.configure do |config|
  r_file = Rails.root.join('config', 'recaptcha.yml').to_s
  r_config = YAML.safe_load(File.open(r_file)).deep_symbolize_keys![Rails.env.to_sym]
  config.site_key   = r_config[:site_key]
  config.secret_key = r_config[:secret_key]
end
