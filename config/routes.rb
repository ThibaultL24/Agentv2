Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    namespace :v1 do
      devise_for :users,
        path: '',
        path_names: {
          sign_in: 'login',
          sign_out: 'logout',
          registration: 'signup'
        },
        controllers: {
          sessions: 'api/v1/sessions',
          registrations: 'api/v1/registrations'
        },
        defaults: { format: :json }

      # Routes publiques pour les currencies et currency_packs
      resources :currencies, only: [:index, :show]
      resources :currency_packs, only: [:index, :show]

      resources :users, only: [:show, :update, :destroy]
      resources :badges do
        collection do
          get 'owned', to: 'badges#owned_badges'
        end
      end
      resources :items
      resources :item_farming
      resources :item_crafting
      resources :item_recharge
      resources :matches
      resources :player_cycles
      resources :nfts, only: [:index, :show, :update, :destroy] do
        collection do
          post 'create'
        end
      end
      resources :user_builds, only: [:index, :show, :update, :destroy] do
        collection do
          post 'create'
        end
      end
      resources :slots

      resources :showrunner_contracts do
        collection do
          get 'owned', to: 'showrunner_contracts#owned_contracts'
        end
        member do
          post 'accept'
          post 'complete'
        end
      end

      resources :rarities, only: [:index, :show]
      resources :types, only: [:index, :show]
      resources :games
      resources :user_slots
      resources :user_recharges, only: [:index, :show, :update]

      resources :badge_useds

      get 'profile', to: 'users#profile'
      patch 'profile', to: 'users#update_profile'
      delete 'profile', to: 'users#delete_profile'
    end
  end

  scope '/payments' do
    # Routes Stripe
    scope '/checkout' do
      post 'create', to: 'checkout#create', as: 'checkout_create'
      get 'success', to: 'checkout#success', as: 'checkout_success'
      get 'cancel', to: 'checkout#cancel', as: 'checkout_cancel'
    end

    # Routes Crypto
    scope '/crypto' do
      post 'metamask', to: 'crypto_payments#metamask'
      get 'verify/:tx_hash', to: 'crypto_payments#verify', constraints: { tx_hash: /0x[a-fA-F0-9]{64}/ }
    end
  end
end
