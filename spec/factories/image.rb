FactoryBot.define do
  factory :image1, class: Image do
    title { ['Image 1'] }
    displays_in { ['dl'] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    creator { ["Creator"] }
    primary_date { ["1900"] }
    contributor { ["Bad Contrib"] }
    temporal { ["Bad Temporal"] }
  end

  factory :image2, class: Image do
    title { ['Image 2'] }
    displays_in { ['dl'] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    contributor { ["Good Contrib"] }
    temporal { ["Good Temporal"] }
  end

  factory :image3, class: Image do
    title { ['Unique Title'] }
    creator { ["Travis"] }
    subject { ["elephant"] }
    displays_in { ['dl'] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
  end

  factory :authenticated_image, class: Image do
    title { ['Tufts Only'] }
    displays_in { ['dl'] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED }
  end
end
