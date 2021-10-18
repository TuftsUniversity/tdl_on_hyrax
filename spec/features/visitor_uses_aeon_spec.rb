# frozen_string_literal: true
require 'rails_helper'

feature 'Visitor goes to homepage' do
  before do
    visit "/" # This can be whatever URL you need it to be
    page.execute_script("localStorage.clear()")
  end
  scenario 'clicks to bring up their empty list', js: true do
    visit root_path
    click_link 'My List'
    expect(page).to have_css("div#aeon-cart-modal", visible: true)
    expect(page).to have_text("Your List is empty!")
  end

  scenario 'adds item to list', js: true do
    visit '/concern/eads/aspace_ms999/fa/aspace_5fc68062788bbf01180b4812d1d5d5cf'
    expect(page).to have_content "Fitzgerald, Zelda 1910-1923"
    click_link "Add to List"
    click_link 'My List'
    expect(page).to have_text "My List : 1 Item"
  end

  scenario 'adds item to list, and requests copies', js: true do
    visit '/concern/eads/aspace_ms999/fa/aspace_5fc68062788bbf01180b4812d1d5d5cf'
    click_link "Add to List"
    click_link 'My List'
    click_button "Request Copies"
    expect(page).to have_text "Reproduction Request"
  end

  scenario 'adds item to list, and requests reading room visit', js: true do
    visit '/concern/eads/aspace_ms999/fa/aspace_5fc68062788bbf01180b4812d1d5d5cf'
    click_link "Add to List"
    click_link 'My List'
    click_button "Request in Reading Room"
    expect(page).to have_text "Reading Room Request"
  end

  scenario 'adds item to list, and saves in TASCR for later use', js: true do
    visit '/concern/eads/aspace_ms999/fa/aspace_5fc68062788bbf01180b4812d1d5d5cf'
    click_link "Add to List"
    click_link 'My List'
    click_button "Save in TASCR"
    expect(page).to have_text "Save in TASCR"
  end

  scenario 'adds item to list, and then removes all items from list', js: true do
    visit '/concern/eads/aspace_ms999/fa/aspace_5fc68062788bbf01180b4812d1d5d5cf'
    click_link "Add to List"
    click_link 'My List'
    click_button('Remove all Items from List')
    expect(page).to have_text "Your List is empty!"
  end
end
