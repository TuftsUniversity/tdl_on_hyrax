# frozen_string_literal: true
require 'rails_helper'

feature 'Audio' do
  before(:all) do
    FactoryBot.create(:tufts_MS123_audio)
  end

  scenario 'View MS123 (Interview with Horace Works) page', js:true do
    visit '/concern/audios/8910jt5bg'
    expect(page).to have_text 'Interview with Horace Works'
    expect(page).to have_text 'Participants'
    expect(page).to have_text 'HW'
    expect(page).to have_text 'Horace Works, interviewee (male)'
    expect(page).to have_text 'KC'
    expect(page).to have_text 'Kenneth J. Cleary, interviewer (male)'
    expect(page).to have_text 'Information'
    expect(page).to have_text 'Transcript'
    #expect(page).to have_text 'view transcript only'
    #expect(page).to have_text 'Can you, can you talk about, can you give any examples of how he motivated you to continue a season when you lost 25 games?'
  end
end
