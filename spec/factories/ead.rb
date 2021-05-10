FactoryBot.define do
  factory :tufts_MS999_ead, class: Ead do
    transient do
      user { FactoryBot.create(:user) } # find_or_create ???
      with_admin_set { false }
    end
    id { 'ks65hc20t' }
    title { ["Lorem Ipsum papers"] }
    displays_in { ['dl'] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    # before(:create) do |work, evaluator|
    # work.ordered_members << create(:file_set, user: evaluator.user, title: ['A Contained FileSet'], id: "BlahBlah0")
    # end

    # after(:build) do |work, evaluator|
    # work.apply_depositor_metadata(evaluator.user.user_key)
    # end

    after(:create) do |work, _evaluator|
      # ead_test_file_1 = File.open(File.expand_path(File.join(Rails.root.to_s, "spec", "fixtures", "MS999.archival.xml")))
      # original_file = work.file_sets[0].build_original_file
      # original_file.content = ead_test_file_1
      #  work.file_sets[0].save
      work.save
    end
  end

  factory :tufts_MS226_ead, class: Ead do
    transient do
      user { FactoryBot.create(:user) } # find_or_create ???
      with_admin_set { false }
    end
    id { 'p2676v52c' }
    title { ['Rubin "Hurricane" Carter papers'] }
    displays_in { ['dl'] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    # before(:create) do |work, evaluator|
    # work.ordered_members << create(:file_set, user: evaluator.user, title: ['A Contained FileSet'], id: "BlahBlah1")
    # end

    # after(:build) do |work, evaluator|
    # work.apply_depositor_metadata(evaluator.user.user_key)
    # end

    after(:create) do |work, _evaluator|
      # ead_test_file_1 = File.open(File.expand_path(File.join(Rails.root.to_s, "spec", "fixtures", "MS226.archival.xml")))
      # original_file = work.file_sets[0].build_original_file
      # original_file.content = ead_test_file_1
      #  work.file_sets[0].save
      work.save
    end
  end
end
