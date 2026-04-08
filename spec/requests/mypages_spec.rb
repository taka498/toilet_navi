require "rails_helper"

RSpec.describe "Mypage", type: :request do
  include AuthHelpers

  let!(:user) do
    User.create!(
      email_address: "mypage-#{SecureRandom.hex(4)}@example.com",
      password_digest: BCrypt::Password.create("password")
    )
  end

  describe "GET /mypage" do
    context "when logged in" do
      it "renders the mypage" do
        sign_in_as(user)

        get "/mypage", headers: auth_headers("ACCEPT" => "text/html")

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("マイページ")
        expect(response.body).to include("お気に入り一覧")
        expect(response.body).to include("評価・投稿一覧")
      end
    end

    context "when not logged in" do
      it "redirects to login or returns 401" do
        get "/mypage", headers: { "ACCEPT" => "text/html" }

        expect([ 302, 401 ]).to include(response.status)
      end
    end
  end
end
