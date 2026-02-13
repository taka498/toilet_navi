require "rails_helper"

RSpec.describe "Signup", type: :request do
  it "サインアップページが表示される" do
    get "/signup"
    expect(response).to have_http_status(:ok)
  end

  it "ユーザー登録できる（確認メール送信→ログイン画面へ）" do
    expect {
      post "/signup", params: {
        user: {
          email_address: "test-#{SecureRandom.hex(8)}@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    }.to change(User, :count).by(1)

    expect(response).to have_http_status(:found)
    expect(response).to redirect_to(new_session_path)
  end
end

