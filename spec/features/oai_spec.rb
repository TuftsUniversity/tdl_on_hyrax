require 'rails_helper'

feature 'OAI-PMH' do
  before do
    FactoryBot.create(:tufts_MS999_ead)
  end

  # Our EAD fixture should be in the oai feed.
  scenario 'Visit the OAI-PMH feed' do
    visit URI.escape('/catalog/oai?verb=ListRecords&metadataPrefix=oai_dc')
    expect(page.body).to include("aspace_ms999")
    expect(page.body).to include("Lorem Ipsum papers, 1897-1933")
  end
end
