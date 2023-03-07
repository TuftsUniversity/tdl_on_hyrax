# frozen_string_literal: true
FactoryBot.define do
  factory :generic_object_with_xml, class: ::GenericObject do
    transient do
      user { FactoryBot.create(:user) } # find_or_create ???
    end
    id { '8910jt5bg' }
    title { ["Interview with Horace Works"] }
    displays_in { ['dl'] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }

    before(:create) do |work, evaluator|
      work.ordered_members << create(:file_set, user: evaluator.user, title: ['A Contained FileSet'], id: "8910jt5fs")
    end

    after(:build) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
    end

    after(:create) do |work, _evaluator|
      tei_test_file = File.open(File.expand_path(Rails.root.join('spec', 'fixtures', 'MS123.001.001.00002.tei.xml')))
      original_file = work.file_sets[0].build_original_file
      original_file.mime_type = 'text/xml'
      original_file.content = tei_test_file
      work.file_sets[0].save
      work.save
    end
  end

  factory :generic_object_with_mp3_missing_mimetype, class: ::GenericObject do
    transient do
      user { FactoryBot.create(:user) } # find_or_create ???
    end
    id { '782466dgh' }
    title { ["Unknown Object"] }
    displays_in { ['dl'] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }

    before(:create) do |work, evaluator|
      work.ordered_members << create(:file_set, user: evaluator.user, title: ['A Contained FileSet'], id: "782466dfs")
    end

    after(:build) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
    end

    after(:create) do |work, _evaluator|
      mp3_test_file = File.open(File.expand_path(Rails.root.join('spec', 'fixtures', 'MS123.001.001.00002.mp3')))
      original_file = work.file_sets[0].build_original_file
      original_file.mime_type = 'none/non'
      original_file.content = mp3_test_file
      work.file_sets[0].save
      work.save
    end
  end
end
