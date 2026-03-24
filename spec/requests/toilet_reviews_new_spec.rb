require "rails_helper"

RSpec.describe "Toilet reviews new", type: :request do
  include AuthHelpers

  let!(:user) do
    User.create!(
      email_address: "test+#{SecureRandom.hex(4)}@example.com",
      password_digest: BCrypt::Password.create("password")
    )
  end

  let!(:station) do
    Station.create!(
      name: "Station A",
      operator_name: "Operator A",
      latitude: 35.681236,
      longitude: 139.767125
    )
  end

  let!(:toilet) do
    Toilet.create!(
      station: station,
      name: "Toilet A",
      latitude: 35.0,
      longitude: 139.0
    )
  end

  describe "GET /toilets/:toilet_id/reviews/new" do
    context "when logged in" do
      it "renders the new page" do
        sign_in_as(user)

        get "/toilets/#{toilet.id}/reviews/new", headers: auth_headers("ACCEPT" => "text/html")

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("レビューを投稿")
        expect(response.body).to include("Toilet A")
      end

      it "shows form help text" do
        sign_in_as(user)

        get "/toilets/#{toilet.id}/reviews/new", headers: auth_headers("ACCEPT" => "text/html")

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("1が低め、5が高評価です。")
        expect(response.body).to include("コメント")
      end
    end

    context "when not logged in" do
      it "redirects to login or returns 401" do
        get "/toilets/#{toilet.id}/reviews/new", headers: { "ACCEPT" => "text/html" }

        expect([ 302, 401 ]).to include(response.status)
      end
    end
  end

  describe "POST /toilets/:toilet_id/reviews" do
    context "when logged in" do
      it "creates a review and redirects to reviews index" do
        sign_in_as(user)

        expect {
          post "/toilets/#{toilet.id}/reviews",
               params: { review: { rating: 4, comment: "使いやすい" } },
               headers: auth_headers("ACCEPT" => "text/html")
        }.to change { Review.count }.by(1)

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(reviews_path)
      end

      it "creates a review with blank comment" do
        sign_in_as(user)

        expect {
          post "/toilets/#{toilet.id}/reviews",
               params: { review: { rating: 4, comment: "" } },
               headers: auth_headers("ACCEPT" => "text/html")
        }.to change { Review.count }.by(1)

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(reviews_path)
      end

      it "re-renders the form when rating is invalid" do
        sign_in_as(user)

        expect {
          post "/toilets/#{toilet.id}/reviews",
               params: { review: { rating: 6, comment: "bad input" } },
               headers: auth_headers("ACCEPT" => "text/html")
        }.not_to change { Review.count }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("入力内容を確認してください")
        expect(response.body).to include("Toilet A")
      end
    end
  end
end
