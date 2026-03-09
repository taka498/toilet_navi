require "rails_helper"

RSpec.describe "Toilet reviews", type: :request do
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

  describe "POST /toilets/:toilet_id/reviews" do
    context "when logged in" do
      it "creates a review with rating only" do
        sign_in_as(user)

        expect {
          post "/toilets/#{toilet.id}/reviews",
               params: { review: { rating: 4, comment: "" } },
               headers: auth_headers("ACCEPT" => "application/json")
        }.to change { Review.count }.by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["rating"]).to eq(4)
        expect(json["comment"]).to eq("")
      end
    end

    context "when not logged in" do
      it "returns 401" do
        post "/toilets/#{toilet.id}/reviews",
             params: { review: { rating: 4, comment: "good" } },
             headers: { "ACCEPT" => "application/json" }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when rating is invalid" do
      it "returns 422" do
        sign_in_as(user)

        expect {
          post "/toilets/#{toilet.id}/reviews",
               params: { review: { rating: 6, comment: "bad input" } },
               headers: auth_headers("ACCEPT" => "application/json")
        }.not_to change { Review.count }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when the same user already reviewed the toilet" do
      it "returns 422" do
        sign_in_as(user)
        Review.create!(user: user, toilet: toilet, rating: 5, comment: "great")

        expect {
          post "/toilets/#{toilet.id}/reviews",
               params: { review: { rating: 4, comment: "again" } },
               headers: auth_headers("ACCEPT" => "application/json")
        }.not_to change { Review.count }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
