Rails.application.routes.draw do
  get 'ad_impressions/create'
  namespace :admin do
    get 'ads/index'
    get 'ads/new'
    get 'ads/create'
    get 'ads/edit'
    get 'ads/update'
    get 'ads/destroy'
    resources :ads do
      member do
        post :create_variant
      end
    end
  end
  require 'sidekiq/web'
  
  # Mount Action Cable
  mount ActionCable.server => '/cable'
  
  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  get 'organization_fields/index'
  get 'organization_fields/create'
  get 'organization_fields/update'
  get 'organization_fields/destroy'
  get 'feed/index'
  
  # Devise routes for user authentication
  devise_for :users, controllers: { 
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  # Root route for public landing page
  root 'home#index' # Public landing page for unauthenticated users

# Organizations and nested pets
resources :organizations do
  resources :pets do
    member do
      get :feed
      post :gallery
      delete :gallery
      get :tasks
    end
    resources :posts, only: [:new, :create, :index, :show, :destroy]
    resources :tasks, only: [:index, :new, :create, :edit, :update, :destroy, :show]
  end
  resources :organization_fields, only: [:index, :create, :update, :destroy]
  resources :posts do
    resources :comments, only: [:create, :destroy]
  end
end


  # Feed page
  resources :feed, only: [:index]

  # Admin namespace for admin-specific home page and potential future admin features
  namespace :admin do
    get 'home', to: 'home#index' # Admin home page
    resources :ads
    resources :users, only: [:index, :new, :create, :edit, :update] do
      collection do
        get :search
      end
      member do
        post :impersonate
        delete :stop_impersonating
      end
    end
  end

  # Shelter staff namespace for shelter-staff-specific home page
  namespace :shelter_staff do
    get 'home', to: 'home#index' # Shelter staff home page
  end

  # User namespace for normal user home page
  namespace :user_home do
    get 'home', to: 'home#index' # Normal user home page
  end

  # Posts namespace for feed and reactions
  resources :posts do
    resources :reactions, only: [:create, :destroy]
    resources :comments, only: [:create, :destroy]
    post :react, on: :member
  end

  resources :ad_impressions, only: [:create]

  resources :comments do
    resources :comment_reactions, only: [:create, :destroy]
  end
end