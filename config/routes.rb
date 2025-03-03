Rails.application.routes.draw do
  namespace :company do
    resources :jobs
    get "profile/show"
    get "profile/edit"
    patch "profile/update"
    
    # 会社ユーザーのルートパス
    root 'profile#show'
  end
  # ログイン関連のルーティング
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  
  # ユーザー登録関連のルーティング
  get '/signup', to: 'users#new'
  post '/users', to: 'users#create'
  
  # 個人ユーザー向けのルーティング
  namespace :individual do
    get 'profile/show'
    get 'profile/edit'
    patch 'profile/update'
    get 'matching/index'
    
    # 個人ユーザーのルートパス
    root 'profile#show'
  end
  
  # 法人ユーザー向けのルーティング
  namespace :corporate do
    # 将来的に法人向け機能を追加
  end
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "users#new"
end
