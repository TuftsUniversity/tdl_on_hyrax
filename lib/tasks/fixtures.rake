# frozen_string_literal: true
namespace :tufts do
  namespace :fixtures do
    desc "Create contribute collections"
    task load_fixtures: :environment do
      if Rails.env.production?
        puts "Don't ingest fixtures in production"
      else
        puts "\nCreating Fixtures"
        Tufts::PopulateFixtures.create_fixtures
      end
    end

    desc "Create contribute collections"
    task delete_fixtures: :environment do
      if Rails.env.production?
        puts "Don't ingest fixtures in production"
      else
        puts "\nEradicating Fixtures"
        Tufts::PopulateFixtures.eradicate_fixtures
      end
    end

    desc "Refresh default Hydra fixtures"
    task refresh: [:delete_fixtures, :load_fixtures]
  end
end
