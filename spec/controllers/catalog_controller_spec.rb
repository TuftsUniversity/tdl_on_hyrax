require 'rails_helper'

RSpec.describe CatalogController, type: :controller do
  it "uses the dl search filter" do
    expect(search_builder.processor_chain).to include :add_dl_filter
  end
end
