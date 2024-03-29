# frozen_string_literal: true
FactoryBot.define do
  factory :user do
    sequence :email do |n|
      "#{n}#{FFaker::Internet.email}"
    end
    sequence :username do |n|
      "#{FFaker::Internet.user_name}#{n}"
    end
    password { 'password' }
    display_name { FFaker::Name.name }
    after(:create) { |user| user.remove_role(:admin) }

    factory :admin do
      after(:create) { |user| user.add_role(:admin) }
    end
  end

  factory :ldap_user, class: User do
    email { 'claire@example.org' }
    username { 'cc414' }
    password { 'retneprac' }
    display_name { 'Claire Carpenter' }
  end

  factory :ldap_admin, class: User do
    email { 'belle@example.org' }
    username { 'bb459' }
    password { 'niwdlab' }
    display_name { 'Belle Baldwin' }
    after(:create) { |user| user.add_role(:admin) }
  end
end
