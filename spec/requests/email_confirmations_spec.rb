require "rails_helper"

RSpec.describe "EmailConfirmations", type: :request do
  describe "GET /email/confirm" do
    it "tokenでメール確認が完了し、完了画面が表示される" do
      user = User.create!(
        email_address: "verify@example.com",
        password: "password123",
        password_confirmation: "password123"
      )

      expect(user.email_confirmation_token).to be_present

      get email_confirmation_path(token: user.email_confirmation_token)

      user.reload
      expect(user.email_confirmed_at).to be_present
      expect(user.email_confirmation_token).to be_nil

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("メール確認が完了しました")
      expect(response.body).to include("ログイン")
      expect(response.body).to include("トイレを探す")
    end

    it "tokenが無効ならトップへ戻してalert（最低限302）" do
      get email_confirmation_path(token: "invalid-token")

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(root_path)
    end
  end
end
