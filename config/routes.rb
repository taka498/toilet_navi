Rails.application.routes.draw do
  resources :toilets, only: [ :index, :show ] do
    resource :favorite, only: %i[create destroy]
  end

  resources :favorites, only: [ :index ]


  get "email_confirmations/show"
  get "users/new"
  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"

  get "/terms",   to: "pages#terms"
  get "/privacy", to: "pages#privacy"
  get "/contact", to: "pages#contact"

  get "/search", to: "search#new"

  # サインアップ（追加）
  get  "/signup", to: "users#new"
  post "/signup", to: "users#create"

  # ログイン/ログアウト（Rails 8 authentication generator）
  resource :session, only: %i[new create destroy edit show update]

  # メールアドレス確認（追加）
  get "/email/confirm", to: "email_confirmations#show", as: :email_confirmation
end
