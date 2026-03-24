require "rails_helper"

RSpec.describe "Toilet reviews index", type: :request do
  include AuthHelpers

  let!(:user1) do
    User.create!(
      email_address: "u1+#{SecureRandom.hex(4)}@example.com",
      password_digest: BCrypt::Password.create("password"),
      display_name: "Alice"
    )
  end

  let!(:user2) do
    User.create!(
      email_address: "u2+#{SecureRandom.hex(4)}@example.com",
      password_digest: BCrypt::Password.create("password"),
      display_name: "Bob"
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

  let!(:toilet1) do
    Toilet.create!(
      station: station,
      name: "Toilet 1",
      latitude: 35.0,
      longitude: 139.0
    )
  end

  let!(:toilet2) do
    Toilet.create!(
      station: station,
      name: "Toilet 2",
      latitude: 35.1,
      longitude: 139.1
    )
  end

  let!(:review1) do
    Review.create!(user: user1, toilet: toilet1, rating: 5, comment: "とても良い")
  end

  let!(:review2) do
    Review.create!(user: user2, toilet: toilet1, rating: 3, comment: "普通")
  end

  let!(:review3) do
    Review.create!(user: user2, toilet: toilet2, rating: 4, comment: "別のトイレ")
  end

  describe "GET /toilets/:toilet_id/reviews" do
    it "shows only reviews for the selected toilet" do
      get "/toilets/#{toilet1.id}/reviews", headers: { "ACCEPT" => "text/html" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Toilet 1")
      expect(response.body).to include("Alice")
      expect(response.body).to include("Bob")
      expect(response.body).to include("とても良い")
      expect(response.body).to include("普通")

      expect(response.body).not_to include("Toilet 2")
      expect(response.body).not_to include("別のトイレ")
    end

    it "shows average rating and review count for the selected toilet" do
      get "/toilets/#{toilet1.id}/reviews", headers: { "ACCEPT" => "text/html" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("平均評価")
      expect(response.body).to include("4.0 / 5")
      expect(response.body).to include("レビュー 2件")
    end

    it "shows no reviews message when the toilet has no reviews" do
      empty_toilet = Toilet.create!(
        station: station,
        name: "Empty Toilet",
        latitude: 35.2,
        longitude: 139.2
      )

      get "/toilets/#{empty_toilet.id}/reviews", headers: { "ACCEPT" => "text/html" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Empty Toilet")
      expect(response.body).to include("平均評価 未評価")
      expect(response.body).to include("レビュー 0件")
      expect(response.body).to include("このトイレにはまだレビューがありません")
    end
  end
end
