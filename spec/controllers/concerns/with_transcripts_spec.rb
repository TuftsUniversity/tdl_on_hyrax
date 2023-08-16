require 'rails_helper'

RSpec.describe WithTranscripts, type: :concern do
  # Create a mock model to include the concern for testing purposes
  let(:test_model) do
    Class.new do
      include WithTranscripts

      attr_accessor :params

      def initialize(params = {})
        @params = params
      end
    end
  end

  subject { test_model.new(params) }

  let(:params) { {} }
  let(:file_set) { double("FileSet", embargo: embargo, original_file: original_file, id: "file_set_id") }
  let(:original_file) { double("OriginalFile", mime_type: "video/mp4", content: "file_content") }
  let(:embargo) { double("Embargo", embargo_release_date: "2023-05-26T00:00:00Z") }

  describe '#load_fedora_document' do
    before do
      allow(ActiveFedora::Base).to receive(:find).and_return(double("Document", file_sets: [file_set]))
    end

    context 'when params[:id] is blank' do
      let(:params) { { id: nil } }

      it 'does not attempt to load the document' do
        expect(ActiveFedora::Base).not_to receive(:find)
        subject.load_fedora_document
      end
    end

    context 'when params[:id] is present' do
      let(:params) { { id: 'test_id' } }

      it 'loads the Fedora document' do
        expect(ActiveFedora::Base).to receive(:find).with('test_id')
        subject.load_fedora_document
      end
    end
  end

  describe '#transcript_embargo?' do
    context 'when file_set has embargo with release date' do
      let(:embargo_release_date) { Date.today + 1.day }

      it 'returns true' do
        expect(subject.transcript_embargo?(file_set)).to be_truthy
      end
    end

    context 'when file_set does not have embargo or release date' do
      let(:embargo) { nil }

      it 'returns false' do
        expect(subject.transcript_embargo?(file_set)).to be_falsey
      end
    end
  end

  describe '#valid_file_type?' do
    context 'when file has a valid mime type' do
      let(:original_file) { double("OriginalFile", mime_type: "text/xml", content: "file_content") }

      before do
        allow(original_file).to receive(:present?).and_return(true)
      end
      it 'returns true' do
        expect(subject.valid_file_type?(original_file)).to be_truthy
      end
    end

    context 'when file does not have a valid mime type' do
      let(:original_file) { double("OriginalFile", mime_type: "invalid/type", content: "file_content") }

      it 'returns false' do
        expect(subject.valid_file_type?(original_file)).to be_falsey
      end
    end
  end

  describe '#process_valid_file_sets' do
    before do
      allow(subject).to receive(:valid_file_type?).and_return(true)
      allow(subject).to receive(:transcript_embargo?).and_return(false)
    end

    it 'processes valid file sets' do
      expect(subject).to receive(:define_file_settings).with(original_file, "file_set_id")
      subject.send(:process_valid_file_sets, [file_set])
    end
  end
end
