require 'factory_girl'

FactoryGirl.define do
  factory :user do
    sequence :email do |n|                       # change :email back to :username when ldap is ready
      "user#{User.count}_#{n}@tufts.edu"         # remove @tufts.edu when ldap is ready
    end
    password 'password'
  end
end
