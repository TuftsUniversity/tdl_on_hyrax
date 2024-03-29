# frozen_string_literal: true
require 'rails_helper'
require 'byebug'

describe HyraxHelper do
  # include ActionView::Helpers
  include described_class

  before do
    FactoryBot.create(:generic_object_with_xml)
    FactoryBot.create(:generic_object_with_mp3_missing_mimetype)
  end

  # rubocop:disable RSpec/InstanceVariable
  it "gets a generic link for a known mimetype" do
    allow(@presenter).to receive(:id).and_return('8910jt5bg')
    expect(generic_link('8910jt5fs')).to eq({ icons: "glyphicon glyphicon-file glyph-left", label: "Download File", text: "Download File", url: "/downloads/8910jt5fs?filename=8910jt5bg.xml" })
  end

  # rubocop:disable RSpec/InstanceVariable
  it "gets a generic link for a unknown mimetype" do
    allow(@presenter).to receive(:id).and_return('782466dgh')
    expect(generic_link('782466dfs')).to eq({ icons: "glyphicon glyphicon-file glyph-left", label: "Download File", text: "Download File", url: "/downloads/782466dfs?filename=782466dgh.non" })
  end
end
