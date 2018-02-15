require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'perform an advanced search', :clean do
  scenario do
    visit '/advanced'
    expect(page).to have_content('More Search Options')
    # fill_in 'Creator', with: pdf.creator
    # click_button 'Search'
    # TODO: work this out when we have fixtures#
  end
end
