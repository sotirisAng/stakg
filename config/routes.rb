Rails.application.routes.draw do

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  get 'trajectories/get_by_name' => 'trajectories#get_by_name'
  resources :points
  resources :trajectories
end
