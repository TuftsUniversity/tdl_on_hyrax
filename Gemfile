# frozen_string_literal: true

source 'https://rubygems.org'

# ruby '2.7.2'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.2.5'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use Puma as the app server
gem 'puma', '~> 4.3'
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
gem 'blacklight_oai_provider'
gem 'blacklight_range_limit', '~> 6.3', '>= 6.3.2'
gem 'devise_ldap_authenticatable'
gem 'easy_logging'
gem 'hydra-role-management'
gem 'ldp', '0.7.0'
gem 'mysql2'
gem 'okcomputer'
gem 'om', git: 'https://github.com/TuftsUniversity/om'
gem 'pdfjs_viewer-rails', git: 'https://github.com/TuftsUniversity/pdfjs_viewer-rails.git', tag: 'tdl-20200428'
gem 'riiif', git: 'https://github.com/TuftsUniversity/riiif', branch: 'tufts_1_7_0'
gem 'sidekiq'
gem 'sitemap_generator'

group :production do
  gem 'passenger'
  gem 'therubyracer'
end

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'geckodriver-helper'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'webdrivers', '~> 4.0', require: false
end

group :development do
  gem 'listen', '~> 3.0.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

gem 'hyrax', '2.9.5'
gem 'tufts-curation', git: 'https://github.com/TuftsUniversity/tufts-curation', branch: 'hyrax-2.9'

group :development, :test do
  gem 'solr_wrapper', '>= 0.3'
end

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
  gem 'factory_bot_rails'
  gem 'ffaker'
  gem 'ladle'
  gem 'simplecov'
  gem 'simplecov-lcov', '~> 0.8.0'
end

gem 'high_voltage', '~> 3.0.0'

# github alerts
gem "bootstrap-sass", ">= 3.4.1"
gem "devise", ">= 4.6.0"
gem "loofah", ">= 2.2.3"
gem "rack", ">= 2.0.6"
gem "rubyzip", ">= 1.2.2"
