# frozen_string_literal: true
require 'rails_helper'

feature 'OAI-PMH' do
  before do
    FactoryBot.create(:tufts_MS123_audio)
  end

  # Our Audio fixture should be in the oai feed.
  scenario 'Visit the OAI-PMH feed for an Audio' do
    visit URI.escape('/catalog/oai?verb=GetRecord&metadataPrefix=oai_dc&identifier=oai:tufts:1234jt5bg')
    expect(page.body).to include('Interview with Horace Works')
  end
end
