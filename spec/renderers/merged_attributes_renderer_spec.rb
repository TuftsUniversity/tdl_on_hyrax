# frozen_string_literal: true
require 'rails_helper'

describe Tufts::Renderers::MergedAttributeRenderer do
  let(:data) { { field1: ['data'], field2: ['other data'] } }
  let(:other_data) { { field2: ['data'], field1: ['other data'] } }

  it 'builds appropriate html' do
    html = described_class.new(data, {}).render
    expect(html).to include('<tr><th>Field1</th>')
    expect(html).not_to include('<tr><th>Field2</th>')
    expect(html).to include('<a href="/catalog?locale=en&amp;q=data&amp;search_field=field1">data</a>')
    expect(html).to include('<a href="/catalog?locale=en&amp;q=other+data&amp;search_field=field2">other data</a>')
  end

  it 'always uses the first field as label' do
    html = described_class.new(other_data, {}).render
    expect(html).to include('<tr><th>Field2</th>')
    expect(html).not_to include('<tr><th>Field1</th>')
  end
end
