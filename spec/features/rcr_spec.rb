# frozen_string_literal: true
require 'rails_helper'

feature 'RCR' do
  before do
    FactoryBot.create(:tufts_RCR00579_rcr)
    let(:presenter) { double(rcr_id: 's1234') }
  end

  scenario 'View RCR00579 ("Tisch Library") page', js: true do
    visit '/concern/rcrs/s4655g578'
    expect(page).to have_text 'Tisch Library, 1996-present'
    expect(page).to have_text 'The Tisch Library (1860-present) opened in 1996, as the main Arts, Sciences, and Engineering ' \
                              'library at Tufts University, made possible by a generous donation from the Tisch family.'
    expect(page).to have_text 'History of Tisch Library'
    expect(page).to have_text 'The Tisch Library (1860-present) opened in 1996, as one of the Arts, Sciences, and ' \
                              'Engineering libraries at Tufts University, made possible by a generous donation from ' \
                              'the Tisch family.'
    expect(page).to have_text 'The library currently houses the collection for the Arts, Sciences and Engineering departments.'
    expect(page).to have_text 'List of head librarians for Eaton/Wessell/Tisch Library:'
    expect(page).to have_text 'President Hosea Ballou (prior to 1861/1862 academic year)'
    expect(page).to have_text 'Laura Wood'
    expect(page).to have_text 'COLLECTIONS'
    expect(page).to have_text 'Tufts Libraries'
    expect(page).to have_text 'Tisch Library, records'
    expect(page).to have_text 'Arts and Sciences Library(Wessell/Tisch), records'
    expect(page).to have_text 'RELATIONSHIPS'
    expect(page).to have_text 'Part of:'
    expect(page).to have_text 'Tufts University (1996-present)'
    expect(page).to have_text 'School of Arts and Sciences (1996-present)'
    expect(page).to have_text 'Associated with:'
    expect(page).to have_text 'Tisch, Jonathan Mark (1996-present)'
    expect(page).to have_text 'University Library Council (2002-present)'
    expect(page).to have_text 'Preceded by:'
    expect(page).to have_text 'Eaton Library (1908-1965)'
    expect(page).to have_text 'Wessell Library (1965-1996)'
  end
end
