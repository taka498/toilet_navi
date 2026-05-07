require "rails_helper"

RSpec.describe "Signup", type: :request do
  it "ユーザー登録できる（登録後にログインしてトップへ遷移する）" do
    post signup_path, params: {
      user: {
        email_address: "test@example.com",
        password: "password",
        password_confirmation: "password"
      }
    }

    expect(response).to redirect_to(root_path)
  end
end
