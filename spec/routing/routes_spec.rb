# frozen_string_literal: true
require 'rails_helper'

describe 'Routes Spec', type: :routing do
  describe 'Sitemaps' do
    describe 'Application Controller' do
      it "routes 'robots.txt', :to => 'application#robots'" do
        expect(get: 'robots.txt').to route_to('application#robots')
      end
    end
  end
end
