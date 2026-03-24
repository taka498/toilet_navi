require "rails_helper"

RSpec.describe "Toilets JSON", type: :request do
  include AuthHelpers

  let!(:user) do
    User.create!(
      email_address: "test+#{SecureRandom.hex(6)}@example.com",
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
      name: "Toilet 1",
      latitude: 35.0,
      longitude: 139.0
    )
  end

  describe "GET /toilets/:id.json" do
    it "includes favorited=true when logged in and favorited" do
      sign_in_as(user)

      # ① ログインが本当に効いているか（ここが 302/401 なら cookie 復号がダメ）
      get "/favorites", headers: auth_headers("Accept" => "text/html")
      expect(response).to have_http_status(:ok)

      # ② まず DB 上は未お気に入りであることを確認
      expect(user.favorites.exists?(toilet_id: toilet.id)).to eq(false)

      # ③ 実装と同じ経路で favorite を作る
      post "/toilets/#{toilet.id}/favorite", headers: auth_headers("Accept" => "application/json")
      expect(response).to have_http_status(:ok)

      # ④ POST の結果として DB にできているかを確定させる（超重要）
      expect(user.favorites.reload.exists?(toilet_id: toilet.id)).to eq(true)

      # ⑤ show を叩いて favorited が true になるか
      get "/toilets/#{toilet.id}.json", headers: auth_headers("Accept" => "application/json")
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["favorited"]).to eq(true)

      get "/favorites", headers: auth_headers
      expect(response.body).to include(toilet.name)
    end

    it "includes reviews and review summary in show json" do
      Review.create!(user: user, toilet: toilet, rating: 5, comment: "とても使いやすい")
      Review.create!(
        user: User.create!(
          email_address: "another+#{SecureRandom.hex(4)}@example.com",
          password: "password"
        ),
        toilet: toilet,
        rating: 3,
        comment: ""
      )

      get "/toilets/#{toilet.id}.json", headers: { "ACCEPT" => "application/json" }
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)

      expect(json["review_summary"]["review_count"]).to eq(2)
      expect(json["review_summary"]["average_rating"]).to eq(4.0)

      expect(json["reviews"].size).to eq(2)
      expect(json["reviews"].first).to include("rating", "comment", "created_at", "user")
    end
  end
end
