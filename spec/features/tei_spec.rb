# frozen_string_literal: true
require 'rails_helper'

feature 'Tei' do
  before do
    FactoryBot.create(:tufts_00091_tei)
    FactoryBot.create(:tufts_00001_tei)
    FactoryBot.create(:tufts_no_legacy_pid_tei)
    FactoryBot.create(:tufts_UP150_001_012_00001_tei)
  end

  scenario 'View High On a Hill TEI Overview' do
    visit '/concern/teis/rj4304528'
    expect(page).to have_text 'High On A Hill'
  end

  scenario 'View History of Tufts College Overview' do
    visit '/concern/teis/5m60qr88b'
    expect(page).to have_text 'History of Tufts College'
  end

  scenario 'View Concise Encyclopedia of Tufts History' do
    visit '/concern/teis/n296wz12m'
    expect(page).to have_text 'Concise Encyclopedia of Tufts History'
  end

  scenario 'View High On a Hill TEI Backpage' do
    visit '/teiviewer/parent/rj4304528/chapter/back001'
    expect(page).to have_text 'APPENDIX A:GUIDE TO ALUMNAE HALL MURALS'
  end

  scenario 'View THE ZETA PSI FRATERNITY AND THE KAPPA CHAPTER' do
    visit '/teiviewer/parent/5m60qr88b/chapter/c7s1'

    expect(page).to have_text 'THE ZETA PSI FRATERNITY AND THE KAPPA CHAPTER'
  end

  scenario 'View 136 HARRISON AVENUE, 1949' do
    visit '/teiviewer/parent/n296wz12m/chapter/num00010'
    expect(page).to have_text 'At a cost of $950,000, Tufts gutted the old building at 136 Harrison Ave and completely renovated the outside and inside.'
  end

  scenario 'View Tufts Medical 52 [yearbook] Overview' do
    visit '/concern/teis/2f75rk37b'
    expect(page).to have_text "Tufts Medical '52 [yearbook]"
  end

  scenario 'View Tufts Medical 52 [yearbook] TOC' do
    visit '/concern/teis/2f75rk37b'
    expect(page).to have_text "Tufts Medical '52, page 20"
  end

  scenario 'View Tufts Medical 52 [yearbook] Cover' do
    visit '/teiviewer/2f75rk37bfs/2f75rk37b'
    expect(page).to have_text "Tufts Medical '52, front pastedown"
  end
end
