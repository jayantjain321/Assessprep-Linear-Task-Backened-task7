Rails.application.routes.draw do
  get "render/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.

  get 'render/index'
   # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

   # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
   # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

   # Defines the root path route ("/")
  root "render#index"

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"

  #task
  resources :tasks, only: [:create, :update, :index]
  get 'task/:id/comments', to: 'tasks#TaskComments'

  #user
  resources :users, only: [:create, :index]
  get 'users/projects', to: 'users#usersProject'
  
  #Comment
  resources :comments, only: [:update, :destroy]
  resources :tasks do
    resources :comments, only: [:create]
  end

  #Project
  resources :projects, only: [:show, :update, :destroy]
  resources :users do
    resources :projects, only: [:create]
  end


  post 'login', to: 'sessions#create'
  
end
