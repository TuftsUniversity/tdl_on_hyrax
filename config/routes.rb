# frozen_string_literal: true
Rails.application.routes.draw do
  concern :oai_provider, BlacklightOaiProvider::Routes.new

  mount Riiif::Engine => 'images', as: :riiif if Hyrax.config.iiif_image_server?

  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
  mount Blacklight::Engine => '/'
  mount BlacklightAdvancedSearch::Engine => '/'
  concern :searchable, Blacklight::Routes::Searchable.new
  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :oai_provider

    concerns :searchable
    concerns :range_searchable
  end
  match '/catalog/:id', to: 'catalog#show_legacy', constraints: { id: /.*/ }, as: 'catalogviewer', via: [:get]
  match '/filtered_catalog(.:format)', to: 'catalog#index', as: 'filteredcatalog', via: [:get]
  match '/bookreader/:parent/:id', to: 'imageviewer#show_book', constraints: { id: /.*/ }, as: 'bookreader', via: [:get]
  match '/pdf_pages/:id/metadata', to: 'pdf_pages#dimensions', constraints: { id: /.*/ }, as: 'pdf_page_metadata', via: [:get]
  match '/pdf_pages/:id/:pageNumber', to: 'pdf_pages#show', constraints: { id: /.*/, pageNumber: /.*/ }, as: 'pdf_page', via: [:get]
  # override welcome route so we can make search bar available on homepage
  # note: this has to go before hyrax is mounted
  root 'catalog#welcome'
  if Rails.env.production? || Rails.env.stage?
    devise_for :users, controllers: { omniauth_callbacks: "omniauthcallbacks" }, skip: [:sessions]
    devise_scope :user do
      match 'sign_in', to: 'omniauth#new', as: :new_user_session, via: [:get, :post]
      post 'sign_in', to: 'omniauth_callbacks#shibboleth', as: :new_session
      get 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
    end
  else
    devise_for :users
  end

  mount Hydra::RoleManagement::Engine => '/'

  # Hide the dashboard from non-admin users.
  non_admin_constraint = lambda do |request|
    !request.env['warden'].authenticate? || !request.env['warden'].user.admin?
  end
  constraints non_admin_constraint do
    get '/dashboard', to: redirect('catalog')
  end

  mount Qa::Engine => '/authorities'
  mount Hyrax::Engine, at: '/'
  resources :welcome, only: 'index'
  mount PdfjsViewer::Rails::Engine => "/pdfjs", as: 'pdfjs'
  curation_concerns_basic_routes
  concern :exportable, Blacklight::Routes::Exportable.new

  match '/robots.txt', to: 'application#robots', via: [:get]
  match '/pdfviewer/:id/:parent', to: 'pdfviewer#index', constraints: { id: /.*/ }, as: 'pdfviewer', via: [:get]

  # Mira uses this to clear the cache on images that have been revised.
  scope module: 'tufts' do
    post 'image_cache_clear', to: 'image_cache_clear#clear_cache'
  end

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  get 'catalog', to: :show, controller: 'catalog'

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  # Streaming video controller
  match '/hls/:id', to: 'tufts/hls#show', as: 'hls', via: [:get]

  get '/image_overlay/:id', to: 'gallery#image_overlay', constraints: { id: /.*/ }, as: 'overlay'
  get '/image_gallery/:id/:start/:number', to: 'gallery#image_gallery', constraints: { id: /.*/ }, as: 'gallery'
  get 'imageviewer/:id', to: 'hyrax/images#advanced', constraints: { id: /.*/ }, as: 'imageviewer'
  get 'gimageviewer/:id', to: 'hyrax/generic_objects#advanced', constraints: { id: /.*/ }, as: 'gimageviewer'
  get 'file_assets/:id', to: 'catalog#legacy_file_assets', constraints: { id: /.*/ }, as: 'fileassetviewer', via: [:get]
  get '/thumb/:id', to: 'catalog#show_thumb_from_id', constraints: { id: /.*/ }, as: 'thumbviewer', via: [:get]
  get 'teiviewer/:parent/:id(/chapter/:chapter)', constraints: { chapter: /[a-zA-Z0-9\-_.:]+/ }, to: 'hyrax/teis#advanced', as: 'teiviewer'
  get 'streetsviewer/:parent/:id(/chapter/:chapter)', constraints: { chapter: /[a-zA-Z0-9\-_.:]+/ }, to: 'hyrax/teis#streets', as: 'streetsviewer'

  get 'concern/audios/:id/transcriptonly', to: 'hyrax/audios#audio_transcriptonly', constraints: { id: /.*/ }, as: 'audio_transcriptonly'
  get 'concern/videos/:id/transcriptonly', to: 'hyrax/videos#video_transcriptonly', constraints: { id: /.*/ }, as: 'video_transcriptonly'

  ele = { object_type_sim: ['Generic Objects'], names_sim: ['American Antiquarian Society'] }
  match '/election_datasets', to: 'catalog#index', f: ele, q: '', search_field: 'all_fields', via: [:get]
end
