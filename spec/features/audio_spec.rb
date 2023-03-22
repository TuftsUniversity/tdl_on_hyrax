# frozen_string_literal: true
require 'rails_helper'

feature 'Audio' do
  before(:all) do
    FactoryBot.create(:tufts_MS123_audio)
  end

  scenario 'View MS123 (Interview with Horace Works) page', js: true do
    visit '/concern/audios/1234jt5bg'
    expect(page).to have_text 'Interview with Horace Works'
    expect(page).to have_text 'TARC Citation Guide'
    expect(page).to have_text 'Participants'
  end

  scenario 'View MS123 (Interview with Horace Works) download links', js: true do
    visit '/concern/audios/1234jt5bg'
    expect(page).to have_link 'Download Audio File'
    expect(page).to have_link 'Download Transcript'
  end

  scenario 'View MS123 (Interview with Horace Works) participants', js: true do
    visit '/concern/audios/1234jt5bg'
    expect(page).to have_text 'HW'
    expect(page).to have_text 'Horace Works, interviewee (male)'
    expect(page).to have_text 'KC'
    expect(page).to have_text 'Kenneth J. Cleary, interviewer (male)'
  end

  scenario 'View MS123 (Interview with Horace Works) information tab visibility', js: true do
    visit '/concern/audios/1234jt5bg'
    expect(page).to have_link 'Information', href: '#information'
    click_link 'Information'
    expect(page).to have_selector('#information', visible: true)
    expect(page).to have_selector('#transcript',  visible: false)
  end

  scenario 'View MS123 (Interview with Horace Works) information tab content', js: true do
    visit '/concern/audios/1234jt5bg'
    expect(page).to have_link 'Information', href: '#information'
    click_link 'Information'
    expect(page).to have_text 'Description'
    expect(page).to have_text 'Interview conducted by Kenneth J. Cleary.'
  end

  scenario 'View MS123 (Interview with Horace Works) transcript tab visibility', js: true do
    visit '/concern/audios/1234jt5bg'
    expect(page).to have_link 'Transcript', href: '#transcript'
    click_link 'Transcript'
    expect(page).to have_selector('#transcript',  visible: true)
    expect(page).to have_selector('#information', visible: false)
  end

  scenario 'View MS123 (Interview with Horace Works) transcript tab content', js: true do
    visit '/concern/audios/1234jt5bg'
    expect(page).to have_link 'Transcript', href: '#transcript'
    click_link 'Transcript'
    expect(page).to have_text 'can you give any examples of how he motivated you'
  end

  scenario 'View MS123 (Interview with Horace Works) transcript only page', js: true do
    visit '/concern/audios/1234jt5bg#transcript'
    expect(page).to have_link 'view transcript only', href: '/concern/audios/1234jt5bg/transcriptonly'
    click_link 'view transcript only'
    expect(page).to have_text 'So the city made a deal with me.'
    expect(page).not_to have_text 'TARC Citation Guide'
  end
end
