Rails.application.routes.draw do
  mount Blacklight::Engine => '/'

  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end

  # override welcome route so we can make search bar available on homepage
  # note: this has to go before hyrax is mounted
  root 'catalog#welcome'

  devise_for :users
  mount Qa::Engine => '/authorities'
  mount Hyrax::Engine, at: '/'
  resources :welcome, only: 'index'

  curation_concerns_basic_routes
  concern :exportable, Blacklight::Routes::Exportable.new
  match '/robots.txt', to: 'application#robots', via: [:get]

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
