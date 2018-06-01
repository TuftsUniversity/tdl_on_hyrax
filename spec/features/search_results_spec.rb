require 'rails_helper'
include TestHelpers
i_need_ldap

feature 'Search Results' do
  let(:admin) { FactoryBot.create(:ldap_admin) }
  let(:authenticated_image) { FactoryBot.create(:authenticated_image) }
  let(:search_results) { '/catalog?f[human_readable_type_sim][]=Image' }

  before(:all) do
    FactoryBot.create(:image1)
    FactoryBot.create(:image2)
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

  scenario "Works with Authenticated visibility only show when user is authenticated" do
    authenticated_image

    visit search_results
    expect(page).not_to have_css(".glyphicon-lock")

    sign_in(admin)
    visit search_results
    # Verify that the glyph is present and in the correct record.
    expect(find("#document_#{authenticated_image.id}")).to have_css(".glyphicon-lock")
  end
end
