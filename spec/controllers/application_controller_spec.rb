require 'rails_helper'

describe ApplicationController do
  describe 'GET #robots' do
    it 'returns http success' do
      get :robots

      expect(response).to be_success
    end
  end
end
