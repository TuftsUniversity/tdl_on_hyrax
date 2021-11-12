# frozen_string_literal: true
FactoryBot.define do
  factory :tufts_no_legacy_pid_tei, class: Tei do
    transient do
      user { FactoryBot.create(:user) } # find_or_create ???
    end
    id { 'rj4304528' }
    title { ["High On A Hill"] }
    displays_in { ['dl'] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    before(:create) do |work, evaluator|
      work.ordered_members << create(:file_set, user: evaluator.user, title: ['A Contained FileSet'], id: "rj4304528fs")
    end

    after(:build) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
    end

    after(:create) do |work, _evaluator|
      tei_test_file1 = File.open(File.expand_path(Rails.root.join('spec', 'fixtures', 'UA069.005.DO.00014.archival.xml')))
      original_file = work.file_sets[0].build_original_file

      original_file.content = tei_test_file1
      work.file_sets[0].save
      work.save
    end
  end

  factory :tufts_00091_tei, class: Tei do
    transient do
      user { FactoryBot.create(:user) } # find_or_create ???
    end
    id { '5m60qr88b' }
    title { ['History of Tufts College'] }
    displays_in { ['dl'] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    before(:create) do |work, evaluator|
      work.ordered_members << create(:file_set, user: evaluator.user, title: ['A Contained FileSet'], id: "5m60qr88bfs")
    end

    after(:build) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
    end

    after(:create) do |work, _evaluator|
      tei_test_file1 = File.open(File.expand_path(Rails.root.join('spec', 'fixtures', 'UA069.005.DO.00091.archival.xml')))
      original_file = work.file_sets[0].build_original_file
      original_file.content = tei_test_file1
      work.file_sets[0].save
      work.save
    end
  end

  factory :tufts_00001_tei, class: Tei do
    transient do
      user { FactoryBot.create(:user) } # find_or_create ???
    end
    id { 'n296wz12m' }
    title { ['Concise Encyclopedia of Tufts History'] }
    displays_in { ['dl'] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    before(:create) do |work, evaluator|
      work.ordered_members << create(:file_set, user: evaluator.user, title: ['A Contained FileSet'], id: "n296wz12mfs")
    end

    after(:build) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
    end

    after(:create) do |work, _evaluator|
      tei_test_file1 = File.open(File.expand_path(Rails.root.join('spec', 'fixtures', 'UA069.005.DO.00001.archival.xml')))
      original_file = work.file_sets[0].build_original_file
      original_file.content = tei_test_file1
      work.file_sets[0].save
      work.save
    end
  end

  factory :tufts_UP150_001_012_00001_tei, class: Tei do
    transient do
      user { FactoryBot.create(:user) } # find_or_create ???
    end
    id { '2f75rk37b' }
    title { ["Tufts Medical '52 [yearbook]"] }
    displays_in { ['dl'] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    before(:create) do |work, evaluator|
      work.ordered_members << create(:file_set, user: evaluator.user, title: ['A Contained FileSet'], id: "2f75rk37bfs")
    end

    after(:build) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
    end

    after(:create) do |work, _evaluator|
      tei_test_file1 = File.open(File.expand_path(Rails.root.join('spec', 'fixtures', 'UP150.001.012.00001.archival.xml')))
      original_file = work.file_sets[0].build_original_file
      original_file.content = tei_test_file1
      work.file_sets[0].save
      work.save
    end
  end
end
