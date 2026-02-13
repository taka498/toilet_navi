require "rails_helper"

RSpec.describe "EmailConfirmations", type: :request do
  describe "GET /email/confirm" do
    it "tokenでメール確認が完了する（email_confirmed_atが入ってtokenが消える）" do
      user = User.create!(
        email_address: "verify@example.com",
        password: "password123",
        password_confirmation: "password123"
      )

      # 作成時にtokenが入っている前提
      expect(user.email_confirmation_token).to be_present

      get email_confirmation_path(token: user.email_confirmation_token)

      user.reload
      expect(user.email_confirmed_at).to be_present
      expect(user.email_confirmation_token).to be_nil
      expect(response).to redirect_to(new_session_path)
    end

    it "tokenが無効ならトップへ戻してalert（最低限302）" do
      get email_confirmation_path(token: "invalid-token")

      expect(response).to have_http_status(:found) # 302
      expect(response).to redirect_to(root_path)
    end
  end
end
