require 'rails_helper'

describe Tufts::Renderers::MergedAttributeRenderer do
  it 'builds appropriate html' do
    data = { field1: ['data'], field2: ['other data'] }
    html = Tufts::Renderers::MergedAttributeRenderer.new(data, {}).render
    expect(html).to include('<tr><th>Field1</th>')
    expect(html).not_to include('<tr><th>Field2</th>')
    expect(html).to include('<a href="/catalog?locale=en&amp;q=data&amp;search_field=field1">data</a>')
    expect(html).to include('<a href="/catalog?locale=en&amp;q=other+data&amp;search_field=field2">other data</a>')
  end

  it 'always uses the first field as label' do
    data = { field2: ['data'], field1: ['other data'] }
    html = Tufts::Renderers::MergedAttributeRenderer.new(data, {}).render
    expect(html).to include('<tr><th>Field2</th>')
    expect(html).not_to include('<tr><th>Field1</th>')
  end
end
