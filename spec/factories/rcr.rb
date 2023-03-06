# frozen_string_literal: true
FactoryBot.define do
  factory :tufts_RCR00579_rcr, class: Rcr do
    transient do
      user { create(:user) } # find_or_create ???
    end
    id { 's4655g578' }
    title { ["Tisch Library"] }
    displays_in { ['dl'] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    before(:create) do |work, evaluator|
      work.ordered_members << create(:file_set, user: evaluator.user, title: ['A Contained FileSet'], id: 'BlahBlah9')
    end

    after(:build) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
    end

    after(:create) do |work, _evaluator|
      rcr_test_file1 = File.open(File.expand_path(Rails.root.join('spec', 'fixtures', 'RCR00579.xml')))
      Hydra::Works::AddFileToFileSet.call(work.file_sets[0], rcr_test_file1, :original_file, versioning: true)
      work.file_sets[0].visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      work.file_sets[0].save
      work.save!
    end
  end
end
