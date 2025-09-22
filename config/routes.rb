# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  devise_for :users, controllers: {
    registrations: 'users/registrations',
  }

  root to: 'products#index'

  resources :products, only: [:index]
  post 'add_to_cart/:product_id', to: 'cart_items#create', as: 'add_to_cart'

  get 'cart', to: 'carts#show', as: 'cart'
  resources :cart_items, only: [:destroy]

  resources :orders, only: %i[new create show] do
    member do
      post :retry_payment
      get  :cancel
      get  :return
    end
  end

  resources :subscriptions, only: %i[new create show] do
    member do
      post :retry_payment
      post :extend_subscription
      patch :toggle_auto_renew
    end
  end

  get 'account', to: 'users#account', as: 'account'
  get '/account/subscriptions', to: 'users#account', defaults: { section: 'subscriptions' }, as: 'account_subscriptions'
  get '/account/orders', to: 'users#account', defaults: { section: 'orders' }, as: 'account_orders'
  get '/account/clients', to: 'users#account', defaults: { section: 'clients' }, as: 'account_clients'

  namespace :espago do
    resources :clients, only: [:show] do
      member do
        patch :toggle_primary
        get :verify
      end
    end

    get 'payments/new', to: 'payments#new', as: 'new_payment'
    post 'payments/reverse', to: 'payments#reverse', as: 'reverse_payment'
    post 'payments/refund', to: 'payments#refund', as: 'refund_payment'
    post 'payments/charge', to: 'payments#charge', as: 'charge'
    get 'payments/:payment_number/success', to: 'payments#payment_success', as: 'payments_success'
    get 'payments/:payment_number/failure', to: 'payments#payment_failure', as: 'payments_failure'
    get 'payments/:payment_number/awaiting', to: 'payments#payment_awaiting', as: 'payments_awaiting'
    post '/back_request',   to: 'back_requests#handle_back_request', as: 'back_request'
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



  if Rails.env.test? || Rails.env.development?
    devise_scope :user do
      post '/sign_in_before_test', to: 'users/sessions#sign_in_before_test'
    end
  end

  match '*unmatched', to: 'application#raise_not_found', via: :all
end
