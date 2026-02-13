require "rails_helper"

RSpec.describe "Login", type: :request do
  it "ログインできる（確認済みユーザー）" do
    email = "test-#{SecureRandom.hex(8)}@example.com"

    User.create!(
      email_address: email,
      password: "password123",
      password_confirmation: "password123",
      email_confirmed_at: Time.current
    )

    post "/session", params: {
      email_address: email,
      password: "password123"
    }

    expect(response).to have_http_status(:found)
  end

  it "パスワードが違うとログインできない" do
    email = "test-#{SecureRandom.hex(8)}@example.com"

    User.create!(
      email_address: email,
      password: "password123",
      password_confirmation: "password123",
      email_confirmed_at: Time.current
    )

    post "/session", params: {
      email_address: email,
      password: "wrong"
    }

    expect(response).to have_http_status(:found)
    expect(response).to redirect_to(new_session_path)
  end
end
