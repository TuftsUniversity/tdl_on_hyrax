require 'rails_helper'
include TestHelpers
i_need_ldap

# Using Instance Variables instead of let() because
# it instantiates 3 things instead of 12 things.
# rubocop:disable RSpec/InstanceVariable
feature 'Search Results' do
  let(:admin) { FactoryBot.create(:ldap_admin) }
  let(:search_results) { '/catalog?f[human_readable_type_sim][]=Image' }

  before(:all) do
    @open_visibility_image = FactoryBot.create(:image1)
    @_im = FactoryBot.create(:image2)
    @authenticated_image = FactoryBot.create(:authenticated_image)
  end

  after(:all) do
    @open_visibility_image.destroy!
    @_im.destroy!
    @authenticated_image.destroy!
  end

  scenario "Contributor shows only when there's no Creator" do
    visit search_results
    within('#search-results') do
      expect(page).to have_text('Good Contrib')
      expect(page).not_to have_text('Bad Contrib')
    end
  end

  scenario "Temporal only shows when there's no Primary Date" do
    visit search_results
    within('#search-results') do
      expect(page).to have_text('Good Temporal')
      expect(page).not_to have_text('Bad Temporal')
    end
  end

  scenario "Lock icon doesn't show on open-visiblity works" do
    visit search_results
    expect(find("#document_#{@open_visibility_image.id}")).not_to have_css(".permissions-lock")
  end

  scenario "Lock icon shows on authenticated-visibility works" do
    sign_in(admin)
    visit search_results
    expect(find("#document_#{@authenticated_image.id}")).to have_css(".permissions-lock")
  end
end
# rubocop:enable RSpec/InstanceVariable
