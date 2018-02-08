namespace :tufts do

  namespace :fixtures do
    desc "Create contribute collections"
    task load_fixtures: :environment do
      Tufts::PopulateFixtures.create_fixtures
    end

    desc "Create contribute collections"
    task delete_fixtures: :environment do
      Tufts::PopulateFixtures.eradicate_fixtures
    end

    desc "Refresh default Hydra fixtures"
    task :refresh => [:delete_fixtures, :load_fixtures]

  end
end
