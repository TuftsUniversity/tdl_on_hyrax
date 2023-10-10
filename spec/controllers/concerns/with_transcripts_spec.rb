# frozen_string_literal: true
require 'rails_helper'

RSpec.describe WithTranscripts, type: :concern do
  # Create a mock model to include the concern for testing purposes
  subject(:model_instance) { test_model.new(params) }

  let(:test_model) do
    Class.new do
      include WithTranscripts

      attr_accessor :params

      def initialize(params = {})
        @params = params
      end
    end
  end

  let(:params) { {} }
  let(:file_set) { instance_double("FileSet", embargo: embargo, original_file: original_file, id: "file_set_id") }
  let(:transcript) { instance_double("FileSet", original_file: transcript_file, id: "file_set_id2") }
  let(:transcript_file) { instance_double("OriginalFile", mime_type: "text/plain", content: "file_content") }
  let(:original_file) { instance_double("OriginalFile", mime_type: "video/mp4", content: "file_content") }
  let(:embargo) { instance_double("Embargo", embargo_release_date: "2023-05-26T00:00:00Z") }

  describe '#load_fedora_document' do
    before do
      allow(ActiveFedora::Base).to receive(:find).and_return(instance_double("Document", file_sets: [file_set, transcript], transcript: transcript))
      model_instance.load_fedora_document
    end

    context 'when params[:id] is blank' do
      let(:params) { { id: nil } }

      it 'does not attempt to load the document' do
        expect(ActiveFedora::Base).not_to have_received(:find)
      end
    end

    context 'when params[:id] is present' do
      let(:params) { { id: 'test_id' } }

      it 'loads the Fedora document' do
        expect(ActiveFedora::Base).to have_received(:find).with('test_id')
      end
    end
  end

  describe '#transcript_embargo?' do
    context 'when file_set has embargo with release date' do
      let(:embargo_release_date) { Time.zone.today + 1.day }

      it 'returns true' do
        expect(model_instance.transcript_embargo?(file_set)).to be_truthy
      end
    end

    context 'when file_set does not have embargo or release date' do
      let(:embargo) { nil }

      it 'returns false' do
        expect(model_instance.transcript_embargo?(file_set)).to be_falsey
      end
    end
  end

  describe '#valid_file_type?' do
    context 'when file has a valid mime type' do
      let(:original_file) { instance_double("OriginalFile", mime_type: "text/xml", content: "file_content") }

      it 'returns true' do
        expect(model_instance.valid_file_type?(original_file)).to be_truthy
      end
    end

    context 'when file does not have a valid mime type' do
      let(:original_file) { instance_double("OriginalFile", mime_type: "invalid/type", content: "file_content") }

      it 'returns false' do
        expect(model_instance.valid_file_type?(original_file)).to be_falsey
      end
    end
  end
end
