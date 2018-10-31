require 'rails_helper'
include TestHelpers
i_need_ldap

feature 'Search Results' do
  let(:admin) { FactoryBot.create(:ldap_admin) }
  let(:search_results) { '/catalog?f[human_readable_type_sim][]=Image' }

  before(:all) do
    @open_visibility_image = FactoryBot.create(:image1)
    FactoryBot.create(:image2)
    # Fedora throws errors if you try to do this in a let() block
    @authenticated_image = FactoryBot.create(:authenticated_image)
  end

  scenario "Contributor shows only when there's no Creator" do
    visit search_results
    expect(page).to have_text("Good Contrib")
    expect(page).not_to have_text("Bad Contrib")
  end

  scenario "Temporal only shows when there's no Primary Date" do
    visit search_results
    expect(page).to have_text("Good Temporal")
    expect(page).not_to have_text("Bad Temporal")
  end

  scenario "Lock icon doesn't show on open-visiblity works" do
    visit search_results
    # rubocop:disable RSpec/InstanceVariable
    expect(find("#document_#{@open_visibility_image.id}")).not_to have_css(".permissions-lock")
    # rubocop:enable RSpec/InstanceVariable
  end

  scenario "Lock icon shows on authenticated-visibility works" do
    sign_in(admin)
    visit search_results
    # Verify that the glyph is present and in the correct record.
    # rubocop:disable RSpec/InstanceVariable
    expect(find("#document_#{@authenticated_image.id}")).to have_css(".permissions-lock")
    # rubocop:enable RSpec/InstanceVariable
  end
end
