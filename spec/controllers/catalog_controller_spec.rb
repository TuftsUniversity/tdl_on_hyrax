# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CatalogController, type: :controller do
  subject(:catalog_controller) { described_class.new }

  it "uses the dl search filter" do
    expect(catalog_controller.search_builder.processor_chain).to include :add_dl_filter
  end

  it 'uses "Thesis Type" as a label isntead of "Dissertation Type"' do
  	config = ::CatalogController.blacklight_config
  	puts config
    vistit '/catalog', { :use_route  => :rails_admin }
    expect(response).to be_successful
    expect(response).to include 'Thesis Type'
  end

end
