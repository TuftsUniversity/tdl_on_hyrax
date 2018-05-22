FactoryBot.define do
  factory :image1, class: Image do
    title { ['Image 1'] }
    displays_in { ['dl'] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    creator { ["Creator"] }
    primary_date { ["1900"] }
    contributor { ["Ba Contrib"] }
    temporal { ["Ba Temporal"] }
  end

  factory :image2, class: Image do
    title { ['Image 2'] }
    displays_in { ['dl'] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    contributor { ["Goo Contrib"] }
    temporal { ["Goo Temporal"] }
  end
end
