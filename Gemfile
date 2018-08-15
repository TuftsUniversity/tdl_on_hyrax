source 'https://rubygems.org'

ruby '2.3.4'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.2'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development
gem 'blacklight_advanced_search'
gem 'blacklight_range_limit', '~> 6.3', '>= 6.3.2'
gem 'coveralls', require: false
gem 'devise_ldap_authenticatable'
gem 'hydra-role-management'
gem 'ldp', '0.7.0'
gem 'mysql2'
gem 'pdfjs_viewer-rails'
gem 'sidekiq'
gem 'sitemap_generator'
gem 'tufts-curation', git: 'https://github.com/TuftsUniversity/tufts-curation', branch: 'master'

# gem 'blacklight_oai_provider', git: 'https://github.com/UNC-Libraries/blacklight_oai_provider.git', branch: 'master'
gem 'blacklight_oai_provider', git: 'https://github.com/TuftsUniversity/blacklight_oai_provider.git', branch: 'master'

group :production do
  gem 'passenger'
  gem 'therubyracer'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'geckodriver-helper'
  gem 'poltergeist'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
end

group :development do
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'hyrax', '2.1.0'
# github: 'samvera/hyrax', ref: 'c42434073491ae65f2e5c37310c8528c6fd63983'

group :development, :test do
  gem 'solr_wrapper', '>= 0.3'
end

gem 'devise'
gem 'devise-guests', '~> 0.6'
gem 'rsolr', '>= 1.0'

group :development, :test do
  gem 'bixby'
  gem 'capybara'
  gem 'fcrepo_wrapper'
  gem 'rubocop', require: false
end

group :test do
  gem 'database_cleaner', '~> 1.3'
  gem "factory_bot_rails"
  gem 'ffaker'
  gem 'ladle'
  gem 'simplecov'
  gem 'simplecov-rcov'
end

gem 'riiif', '~> 1.1'

gem 'high_voltage', '~> 3.0.0'
