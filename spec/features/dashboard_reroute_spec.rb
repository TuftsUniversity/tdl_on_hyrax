# frozen_string_literal: true
require 'rails_helper'
include TestHelpers
i_need_ldap

feature 'Logging in reroutes to front page if not an admin.' do
  let(:user) { FactoryBot.create(:ldap_user) }
  let(:admin) { FactoryBot.create(:ldap_admin) }

  scenario 'non-admin cannot access dashboard', js: true do
    sign_in(user)
    expect(current_path).to eq('/catalog')
    visit('/dashboard')
    expect(current_path).to eq('/catalog')
  end

  scenario 'admin gets redirected to the dashboard' do
    sign_in(admin)
    expect(current_path).to eq('/dashboard')
  end
end
