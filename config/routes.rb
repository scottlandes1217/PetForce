Rails.application.routes.draw do
  get 'organization_fields/index'
  get 'organization_fields/create'
  get 'organization_fields/update'
  get 'organization_fields/destroy'
  get 'feed/index'
  # Devise routes for user authentication
  devise_for :users

  # Root route for public landing page
  root 'home#index' # Public landing page for unauthenticated users

# Organizations and nested pets
resources :organizations do
  resources :pets do
    member do
      match :gallery, via: [:get, :post, :delete]
    end
    resources :posts, only: [:new, :create, :index, :show, :destroy]
    resources :tasks, only: [:index, :new, :create, :edit, :update, :destroy, :show]
  end
  resources :organization_fields, only: [:index, :create, :update, :destroy]
end


  # Feed page
  resources :feed, only: [:index]

  # Admin namespace for admin-specific home page and potential future admin features
  namespace :admin do
    get 'home', to: 'home#index' # Admin home page
  end

  # Shelter staff namespace for shelter-staff-specific home page
  namespace :shelter_staff do
    get 'home', to: 'home#index' # Shelter staff home page
  end

  # User namespace for normal user home page
  namespace :user do
    get 'home', to: 'home#index' # Normal user home page
  end

  # Posts namespace for feed and reactions
  resources :posts do
    # Existing nested routes for reactions, etc.
    resources :reactions, only: [:create, :destroy]
  
    # Add this line for the custom "react" action on a specific post
    post :react, on: :member
  end
end