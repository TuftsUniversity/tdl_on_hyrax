Rails.application.routes.draw do
  mount Riiif::Engine => 'images', as: :riiif if Hyrax.config.iiif_image_server?
  concern :oai_provider, BlacklightOaiProvider::Routes::Provider.new

  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
  mount Blacklight::Engine => '/'
  mount BlacklightAdvancedSearch::Engine => '/'
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :oai_provider

    concerns :searchable
    concerns :range_searchable
  end

  # override welcome route so we can make search bar available on homepage
  # note: this has to go before hyrax is mounted
  root 'catalog#welcome'

  devise_for :users
  mount Hydra::RoleManagement::Engine => '/'

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

  get 'concern/eads/:id/fa', to: 'hyrax/eads#fa_overview', constraints: { id: /.*/ }, as: 'fa_overview'
  get 'concern/eads/:id/fa/:item_id', to: 'hyrax/eads#fa_series', constraints: { id: /.*/, item_id: /.*/ }, as: 'fa_series'
  get 'concern/audios/:id/transcriptonly', to: 'hyrax/audios#audio_transcriptonly', constraints: { id: /.*/ }, as: 'audio_transcriptonly'
  get 'concern/videos/:id/transcriptonly', to: 'hyrax/videos#video_transcriptonly', constraints: { id: /.*/ }, as: 'video_transcriptonly'

  match 'feedback', to: 'feedback#show', via: [:post]

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
