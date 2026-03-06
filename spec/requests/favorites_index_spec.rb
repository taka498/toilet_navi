require "rails_helper"

RSpec.describe "Favorites index", type: :request do
  let!(:user1) { create_test_user(email: "u1@example.com") }
  let!(:user2) { create_test_user(email: "u2@example.com") }

  let!(:station) do
    Station.create!(
      name: "Station A",
      operator_name: "Operator A",
      latitude: 35.681236,   # 東京駅付近（例）
      longitude: 139.767125  # 東京駅付近（例）
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

  before do
    Favorite.create!(user: user1, toilet: toilet1)
    Favorite.create!(user: user2, toilet: toilet2)
  end

  context "when logged in" do
    it "shows only current user's favorites" do
      sign_in_as(user1)
      get "/favorites", headers: auth_headers

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Toilet 1")
      expect(response.body).not_to include("Toilet 2")
    end
  end

  context "when not logged in" do
    it "redirects to login (or returns 401 depending on your implementation)" do
      get "/favorites"
      expect([ 302, 401 ]).to include(response.status)
    end
  end
end
