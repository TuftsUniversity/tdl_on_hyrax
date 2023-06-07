# frozen_string_literal: true
require 'rails_helper'

feature 'OAI-PMH' do
  before(:each) do
    FactoryBot.create(:tufts_MS999_ead)
    FactoryBot.create(:tufts_MS123_audio)
  end

  # Our EAD fixture should be in the oai feed.
  scenario 'Visit the OAI-PMH feed for an EAD' do
    visit URI.escape('/catalog/oai?verb=GetRecord&metadataPrefix=oai_dc&identifier=oai:tufts:ks65hc20t')
    expect(page.body).to include('Lorem Ipsum papers')
  end

  # Our Audio fixture should be in the oai feed.
  scenario 'Visit the OAI-PMH feed for an Audio' do
    visit URI.escape('/catalog/oai?verb=GetRecord&metadataPrefix=oai_dc&identifier=oai:tufts:8910jt5bg')
    expect(page.body).to include('Interview with Horace Works')
  end
end
