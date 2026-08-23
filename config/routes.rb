Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root to: redirect("/projects")

  namespace :auth do
    resources :registrations, only: %i[new create]
    resources :sessions, only: %i[new create]
    delete "sessions/destroy", to: "sessions#destroy", as: :logout
  end

  resources :projects, only: %i[index show new create] do
    resources :items, only: :update
    resources :lists, only: %i[new create] do
      resources :items, only: :create
    end
  end
  resources :items, only: %i[show edit update] do
    resources :events, only: %i[new create], controller: "item/events"
  end
end
