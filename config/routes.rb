Rails.application.routes.draw do
  # health check
  get "up" => "rails/health#show", as: :rails_health_check

  # トップページ
  root "pages#home"

  # 静的ページ
  get "/terms",   to: "pages#terms"
  get "/privacy", to: "pages#privacy"
  get "/contact", to: "pages#contact"

  # トイレ表示画面
  get "/search", to: "search#new"

  # （将来）ログイン・サインアップ
  # get "/login",  to: "sessions#new"
  # get "/signup", to: "users#new"
end
