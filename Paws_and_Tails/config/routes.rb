Rails.application.routes.draw do
  # get 'animal/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "animals#index"
  resources :animals
  resources :breeders

  post "/animals/api/sort_location", to: "animals#sort_location"

  # get "/animals", to: "animals#index"
  # get "/animals/:id", to: "animals#show"
end
