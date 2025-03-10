Rails.application.routes.draw do
  # テスト環境でのみ使用するルート
  if Rails.env.test?
    get '/test', to: 'test#index'
  end

  namespace :company do
    get "matching/index"
    get "matching/show"
    get "matching/like"
    resources :jobs
    get "profile/show"
    get "profile/edit"
    patch "profile/update"
    
    # マッチング機能
    resources :matching, only: [:index, :show] do
      collection do
        get :search
      end
      member do
        post :like
        delete :unlike
      end
    end
    
    # メッセージ機能
    resources :messages, only: [:index, :show, :create] do
      collection do
        get :unread_count
      end
    end
    
    # 請求機能
    resources :invoices, only: [:index, :show] do
      member do
        patch :mark_as_paid
        get :download_pdf
        get :print_preview
      end
    end
    
    # 会社ユーザーのルートパス
    root 'profile#show'
  end
  # ログイン関連のルーティング
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  get '/logout', to: 'sessions#destroy'
  
  # ユーザー登録関連のルーティング
  get '/signup', to: 'users#new'
  post '/users', to: 'users#create'
  
  # 個人ユーザー向けのルーティング
  namespace :individual do
    get 'profile/show'
    get 'profile/edit'
    patch 'profile/update'
    get 'matching/index'
    resources :matching, only: [:index, :show] do
      member do
        post 'like'
        delete 'unlike'
      end
    end
    
    # メッセージ機能
    resources :messages, only: [:index, :show, :create] do
      collection do
        get :unread_count
      end
    end
    
    # 個人ユーザーのルートパス
    root 'profile#show'
  end
  
  # 法人ユーザー向けのルーティング
  namespace :corporate do
    # 将来的に法人向け機能を追加
  end
  
  # 法的ページのルート
  scope '/legal' do
    get 'commerce', to: 'legal#commerce'
    get 'privacy', to: 'legal#privacy'
    get 'terms', to: 'legal#terms'
  end
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
end
