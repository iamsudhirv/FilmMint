Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :data_sources, only: %i[index show]
      get "dashboard", to: "dashboard#show"
      resources :industries, only: :index
      resources :films, only: :index
      resources :territories, only: :index
      resources :people, only: %i[index show]
      resources :projects do
        resources :package_members, only: %i[create update destroy]
        resource :valuation, only: :show do
          get :what_if
        end
      end
      get "connections/network", to: "connections#network"
      get "connections/path", to: "connections#path"
      post "connections", to: "connections#create"
    end
  end
end
