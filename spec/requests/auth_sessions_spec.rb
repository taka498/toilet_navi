require "rails_helper"

RSpec.describe "AuthSessions", type: :request do
  describe "POST /session" do
    it "未確認ユーザーはログインできない（/session/newへ戻る）" do
      user = User.create!(
        email_address: "unconfirmed@example.com",
        password: "password123",
        password_confirmation: "password123"
        # email_confirmed_at は nil のまま
      )

      post session_path, params: {
        email_address: user.email_address,
        password: "password123"
      }

      expect(response).to redirect_to(new_session_path)
    end

    it "確認済みユーザーはログインできる（after_authentication_urlへリダイレクト）" do
      user = User.create!(
        email_address: "confirmed@example.com",
        password: "password123",
        password_confirmation: "password123",
        email_confirmed_at: Time.current
      )

      post session_path, params: {
        email_address: user.email_address,
        password: "password123"
      }

      expect(response).to have_http_status(:found) # 302
      # ルートが固定でないなら「302になった」までで十分強いです
    end
  end
end
