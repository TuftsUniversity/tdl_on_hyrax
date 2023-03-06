# frozen_string_literal: true
require 'rails_helper'
require 'byebug'

describe HyraxHelper do
  include ActionView::Helpers
  include HyraxHelper

  FactoryBot.create(:generic_object_1)


  it "gets a generic link" do
    allow(@presenter).to receive(:id).and_return('8910jt5bg')
    object = ActiveFedora::Base.find('8910jt5bg')
    file_set = object.file_sets[0]
    expect(generic_link(file_set.id)).to eq({:icons=>"glyphicon glyphicon-file glyph-left", :label=>"Download File", :text=>"Download File", :url=>"/downloads/8910jt5fs?filename=8910jt5bg.xml"})
  end
end