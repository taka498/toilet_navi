require "rails_helper"

RSpec.describe "AuthSessions", type: :request do
  describe "POST /session" do
    it "ユーザーはログインできる" do
      user = User.create!(
        email_address: "confirmed@example.com",
        password: "password123",
        password_confirmation: "password123"
      )

      post session_path, params: {
        email_address: user.email_address,
        password: "password123"
      }

      expect(response).to redirect_to(root_path)
    end
  end
end
