# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::RcrPresenter do
  let(:presenter) { described_class.new(double, nil) }

  describe '#rcr_id' do
    context 'when file_set_presenters returns nil' do
      before do
        allow(presenter).to receive(:file_set_presenters).and_return(nil)
      end

      it 'returns nil' do
        expect(presenter.rcr_id).to be_nil
      end
    end

    context 'when there is a file_set_presenter with mime_type "text/xml"' do
      # rubocop:disable RSpec/VerifiedDoubles:
      let(:xml_fsp) { double(id: '123', mime_type: 'text/xml') }

      before do
        allow(presenter).to receive(:file_set_presenters).and_return([xml_fsp])
      end

      it 'returns the id of the xml file_set_presenter' do
        expect(presenter.rcr_id).to eq('123')
      end
    end

    context 'when there is no file_set_presenter with mime_type "text/xml"' do
      # rubocop:disable RSpec/VerifiedDoubles:
      let(:other_fsp) { double(id: '456', mime_type: 'text/plain') }

      before do
        allow(presenter).to receive(:file_set_presenters).and_return([other_fsp])
      end

      it 'returns nil' do
        expect(presenter.rcr_id).to be_nil
      end
    end
  end
end
