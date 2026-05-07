require "rails_helper"

RSpec.describe "AuthSessions", type: :request do
  describe "POST /session" do
    it "ユーザーはログインできる" do
      post session_path, params: {
        email_address: user.email_address,
        password: "password"
      }

      expect(response).to redirect_to(root_path)
    end
  end
end
