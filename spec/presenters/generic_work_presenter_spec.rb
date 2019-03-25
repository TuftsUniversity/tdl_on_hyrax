require 'rails_helper'

describe Hyrax::GenericWorkPresenter do
  describe 'multi_attributes_to_html' do
    let(doc) { SolrDocument.new }
    let(user) { FactoryBot.build(:ldap_admin) }
    let(ability) { Ability.new(user) }

    it 'returns nothing if there are no fields' do
      presenter = described_class.new(doc, ability)
      html = presenter.multi_attributes_to_html({})
      expect(html).to eq('')
    end
  end
end
