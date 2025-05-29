require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  devise_for :users, controllers: {
    registrations: 'users/registrations',
  }

  root to: 'rubits#index', via: %i[get post]
  resources :rubits, only: %i[show create destroy] do
    resources :likes, only: %i[create destroy]
  end

  resources :products, only: [:index]
  post 'add_to_cart/:product_id', to: 'cart_items#create', as: 'add_to_cart'

  get 'cart', to: 'carts#show', as: 'cart'
  resources :cart_items, only: [:destroy]

  resources :orders, only: %i[new create show]

  get 'account', to: 'users#account', as: 'account'

  namespace :espago do
    namespace :secure_web_page do
      get 'payments/:id/start_payment', to: 'payments#start_payment', as: 'start_payment'
      get  'payments/success',       to: 'payments#payment_success'
      get  'payments/failure',       to: 'payments#payment_failure'
      post '/back_request',          to: 'back_requests#handle_back_request', as: 'back_request'
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  match '*unmatched', to: 'application#raise_not_found', via: :all
end
