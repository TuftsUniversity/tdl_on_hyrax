# frozen_string_literal: true
require 'rails_helper'

feature 'Title, creator, and subject basic searches', js: true do
  before(:all) do
    FactoryBot.create(:image1)
    FactoryBot.create(:image3)
  end

  scenario 'searches for title correctly' do
    basic_search('Title', 'unique')
    expect(page).to have_text('Unique Title')
    expect(page).not_to have_text('Image 1')
  end

  scenario 'searches for creator correctly' do
    basic_search('Creator/Author', 'Travis')
    expect(page).to have_text('Unique Title')
    expect(page).not_to have_text('Image 1')
  end

  scenario 'searches for subject correctly' do
    basic_search('Subject', 'elephant')
    expect(page).to have_text('Unique Title')
    expect(page).not_to have_text('Image 1')
  end
end
