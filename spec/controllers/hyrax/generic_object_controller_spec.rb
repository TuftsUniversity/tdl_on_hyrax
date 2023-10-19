# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::GenericObjectsController, type: :controller do
  routes { Rails.application.routes }

  let(:generic_object) { FactoryBot.create(:generic_object_with_xml) }

  describe 'GET #advanced' do
    context 'when the object exists' do
      before do
        get :advanced, params: { id: generic_object.id }
        request.env['warden'] = instance_double("Warden::Proxy").as_null_object
      end

      it 'assigns the correct id' do
        expect(assigns(:id)).to eq(generic_object.id)
      end

      it 'renders the imageviewer layout' do
        expect(response).to render_template(layout: 'imageviewer')
      end

      it 'responds with success' do
        expect(response).to be_successful
      end
    end

    context 'when the object does not exist' do
      it 'raises a record not found error' do
        expect do
          get :advanced, params: { id: 'nonexistent' }
        end.to raise_error(ActiveFedora::ObjectNotFoundError)
      end
    end
  end
end
