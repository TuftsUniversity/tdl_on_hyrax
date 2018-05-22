require 'rails_helper'

feature 'Search Results' do

  before(:all) do
    FactoryBot.create(:image1)
    FactoryBot.create(:image2)
  end

  scenario "Contributor shows only when there's no Creator" do
    #visit '/catalog?f%5Bhuman_readable_type_sim%5D%5B%5D=Image'
    visit '/catalog?f[human_readable_type_sim][]=Image'
    expect(page).to have_text("Good Contrib")
    expect(page).not_to have_text("Bad Contrib")
  end

  scenario "Temporal only shows when there's no Primary Date" do
    visit '/catalog?f[human_readable_type_sim][]=Image'
    expect(page).to have_text("Good Temporal")
    expect(page).not_to have_text("Bad Temporal")
  end
end
