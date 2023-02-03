# frozen_string_literal: true
require 'rails_helper'

feature 'Audio' do
  before(:all) do
    FactoryBot.create(:tufts_MS123_audio)
  end

  scenario 'View MS123 (Interview with Horace Works) page', js: true do
    visit '/concern/audios/1234jt5bg'
    expect(page).to have_text 'Interview with Horace Works'
    expect(page).to have_text 'DCA Citation Guide'
  end

  scenario 'View MS123 (Interview with Horace Works) participants', js: true do
    visit '/concern/audios/1234jt5bg'
    expect(page).to have_text 'Participants'
    expect(page).to have_text 'HW'
    expect(page).to have_text 'Horace Works, interviewee (male)'
    expect(page).to have_text 'KC'
    expect(page).to have_text 'Kenneth J. Cleary, interviewer (male)'
  end

  scenario 'View MS123 (Interview with Horace Works) information tab', js: true do
    visit '/concern/audios/1234jt5bg'
    expect(page).to have_link 'Information', href: '#information'
    expect(page).to have_text 'Description'
    expect(page).to have_text 'Interview conducted by Kenneth J. Cleary.'
  end

  scenario 'View MS123 (Interview with Horace Works) transcript tab', js: true do
    visit '/concern/audios/1234jt5bg'
    expect(page).to have_link 'Transcript', href: '#transcript'
    click_link 'Transcript'
    expect(page).to have_text 'Can you, can you talk about, can you give any examples of how he motivated you to continue a season when you lost 25 games?'
  end

  scenario 'View MS123 (Interview with Horace Works) transcript only page', js: true do
    visit '/concern/audios/1234jt5bg'
    expect(page).to have_link 'view transcript only', href: '/concern/audios/1234jt5bg/transcriptonly'
    click_link 'view transcript only'
    expect(page).to have_text 'So the city made a deal with me.'
    expect(page).not_to have_text 'DCA Citation Guide'
  end
end
