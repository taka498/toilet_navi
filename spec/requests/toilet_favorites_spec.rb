# spec/requests/toilet_favorites_spec.rb
require "rails_helper"

RSpec.describe "Toilet favorites", type: :request do
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
      name: "Toilet A",
      latitude: 35.0,
      longitude: 139.0
    )
  end

  describe "POST /toilets/:id/favorite" do
    context "when logged in" do
      it "creates favorite and returns favorited: true (json)" do
        sign_in_as(user)

        expect {
          post "/toilets/#{toilet.id}/favorite", headers: auth_headers("ACCEPT" => "application/json")
        }.to change { Favorite.where(user: user, toilet: toilet).count }.by(1)

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["favorited"]).to eq(true)
      end
    end

    context "when already favorited" do
      it "does not create duplicate favorite and still returns favorited: true" do
        sign_in_as(user)
        Favorite.create!(user: user, toilet: toilet)

        expect {
          post "/toilets/#{toilet.id}/favorite", headers: auth_headers("ACCEPT" => "application/json")
        }.not_to change { Favorite.where(user: user, toilet: toilet).count }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["favorited"]).to eq(true)
      end
    end

    context "when not logged in" do
      it "returns 401" do
        post "/toilets/#{toilet.id}/favorite", headers: { "ACCEPT" => "application/json" }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /toilets/:id/favorite" do
    context "when logged in" do
      it "destroys favorite and returns favorited: false (json)" do
        sign_in_as(user)
        Favorite.create!(user: user, toilet: toilet)

        expect {
          delete "/toilets/#{toilet.id}/favorite", headers: auth_headers("ACCEPT" => "application/json")
        }.to change { Favorite.where(user: user, toilet: toilet).count }.by(-1)

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["favorited"]).to eq(false)
      end
    end

    context "when another user's favorite exists" do
      it "does not affect another user's favorite" do
        other_user = User.create!(
          email_address: "other+#{SecureRandom.hex(6)}@example.com",
          password_digest: BCrypt::Password.create("password")
        )

        Favorite.create!(user: other_user, toilet: toilet)

        sign_in_as(user)

        expect {
          delete "/toilets/#{toilet.id}/favorite", headers: auth_headers("ACCEPT" => "application/json")
        }.not_to change { Favorite.where(user: other_user, toilet: toilet).count }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["favorited"]).to eq(false)
      end
    end

    context "when favorite does not exist" do
      it "returns ok and favorited: false (idempotent)" do
        sign_in_as(user)

        expect {
          delete "/toilets/#{toilet.id}/favorite", headers: auth_headers("ACCEPT" => "application/json")
        }.not_to change { Favorite.where(user: user, toilet: toilet).count }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["favorited"]).to eq(false)
      end
    end

    context "when not logged in" do
      it "returns 401" do
        delete "/toilets/#{toilet.id}/favorite", headers: { "ACCEPT" => "application/json" }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
