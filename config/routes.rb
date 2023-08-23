Rails.application.routes.draw do
  devise_for :users
  resources :flights
  resources :flight_files
  resources :logfiles
  resources :trajectories do
    member do
      post :enrich_trajectory_with_weather
      post :create_recording_segments
      post :enrich_with_pois_from_aegean
      post :enrich_with_pois_from_osm
      post :add_recording_positions_from_flight_records
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root to: "application#home"
  get 'trajectories/get_by_name' => 'trajectories#get_by_name'
  resources :points
  resources :trajectories, except: [:create]

  resources :uploads#, only: [:new, :create, :index]

  get 'logfiles/:id/get_file' => 'logfiles#get_file'
  get 'logfiles/:id/get_url_for_file' => 'logfiles#get_url_for_file'
  get 'flight_files/:id/get_file' => 'flight_files#get_file'

  post 'flights/:id/create_trajectory_from_flight' => 'flights#create_trajectory_from_flight'#, as: :create_trajectory_from_flight

  post 'trajectories/create_trajectory_from_flight/:flight_id' => 'trajectories#create_trajectory_from_flight', as: :create_trajectory_from_flight

  get 'records/:id/show' => 'records#show'

  get 'onto4drone/:id' => 'rdf_resource#show'

end
