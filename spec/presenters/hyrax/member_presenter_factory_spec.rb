# frozen_string_literal: true
RSpec.describe Hyrax::MemberPresenterFactory do
  describe "#file_set_presenters" do
    describe "getting presenters from factory" do
      let(:solr_document) { SolrDocument.new(attributes) }
      let(:attributes) { {} }
      let(:ability) { double }
      let(:request) { double }
      let(:factory) { described_class.new(solr_document, ability, request) }
      let(:presenter_class) { double }

      before do
        allow(factory).to receive(:composite_presenter_class).and_return(presenter_class)
        allow(factory).to receive(:ordered_ids).and_return(['12', '33'])
        allow(factory).to receive(:file_set_ids).and_return(['33', '12'])
      end

      # rubocop:disable RSpec/MessageSpies
      it "uses the set class" do
        expect(Hyrax::PresenterFactory).to receive(:build_for)
          .with(ids: ['12', '33'],
                presenter_class: presenter_class,
                presenter_args: [ability, request])
        factory.file_set_presenters
      end
    end
  end
end
