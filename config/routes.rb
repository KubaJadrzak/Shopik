# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  devise_for :users, controllers: {
    registrations: 'users/registrations',
  }

  root to: 'products#index'

  resources :products, only: [:index]

  resource :cart, only: [:show]

  resources :cart_items, only: [:destroy]
  post 'add_to_cart/:product_id', to: 'cart_items#create', as: 'add_to_cart'

  resources :orders, param: :uuid, only: %i[new create show] do
    member do
      post :retry_payment
      get  :cancel
      get  :return
    end
  end

  resources :subscriptions, param: :uuid, only: %i[new create show]

  resources :clients, param: :uuid, only: %i[show destroy] do
    member do
      get :authorize
      post :authorize
      patch :toggle_primary
    end
  end


  get 'account', to: 'users#account', as: 'account'
  get '/account/subscriptions', to: 'users#account', defaults: { section: 'subscriptions' }, as: 'account_subscriptions'
  get '/account/orders', to: 'users#account', defaults: { section: 'orders' }, as: 'account_orders'
  get '/account/clients', to: 'users#account', defaults: { section: 'clients' }, as: 'account_clients'


  resources :payments, param: :uuid,  only: %i[new create show] do
    member do
      post :reverse
      post :refund
      get :success
      get :pending
      get :rejected
    end
  end

  post '/back_request',   to: 'back_requests#receive', as: 'back_request'

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
