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

  #users
  namespace :api do
    namespace :v1 do
      resources :users, only: [:create, :index]
      get 'users/projects', to: 'users#userProjects'
      get 'users/tasks', to: 'users#userTasks'
    end
  end

  # Tasks
  namespace :api do
    namespace :v1 do
      resources :tasks, only: [:create, :update, :index, :destroy] do
        member do
          put 'restore' # Defines a route for restoring a specific task with :id
        end
      end
      get 'task/:id/comments', to: 'tasks#TaskComments'
    end
  end

  # Comments
  namespace :api do
    namespace :v1 do
      resources :comments, only: [:update, :destroy] do
        member do
          put 'restore' # Defines a route for restoring a specific comment with :id
        end
      end
      resources :tasks do
        resources :comments, only: [:create]
      end
    end
  end

  # Projects
  namespace :api do
    namespace :v1 do
      resources :projects, only: [:show, :update, :destroy, :index] do
        member do
          put 'restore' # Defines a route for restoring a specific project with :id
        end
      end
      resources :users do
        resources :projects, only: [:create]
      end
    end
  end


  #refresh-token and login
  namespace :api do
    namespace :v1 do
      post 'login', to: 'sessions#create'
      post 'refresh', to: 'sessions#refresh_token'
    end
  end
  
end
