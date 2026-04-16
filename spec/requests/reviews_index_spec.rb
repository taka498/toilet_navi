require "rails_helper"

RSpec.describe "Reviews index", type: :request do
  include AuthHelpers

  let!(:user1) do
    User.create!(
      email_address: "u1+#{SecureRandom.hex(4)}@example.com",
      password_digest: BCrypt::Password.create("password")
    )
  end

  let!(:user2) do
    User.create!(
      email_address: "u2+#{SecureRandom.hex(4)}@example.com",
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
    Review.create!(user: user2, toilet: toilet2, rating: 3, comment: "普通")
  end

  before do
    review1.image.attach(
      io: Rails.root.join("spec/fixtures/files/review_image.png").open,
      filename: "review_image.png",
      content_type: "image/png"
    )
  end

  describe "GET /reviews" do
    context "when logged in" do
      it "shows only current user's reviews" do
        sign_in_as(user1)

        get "/reviews", headers: auth_headers("ACCEPT" => "text/html")

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Toilet 1")
        expect(response.body).to include("とても良い")
        expect(response.body).not_to include("Toilet 2")
        expect(response.body).not_to include("普通")
      end

      it "shows an attached image in the current user's reviews list" do
        sign_in_as(user1)

        get "/reviews", headers: auth_headers("ACCEPT" => "text/html")

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("review_image.png")
      end
    end

    context "when not logged in" do
      it "redirects to login or returns 401" do
        get "/reviews", headers: { "ACCEPT" => "text/html" }
        expect([ 302, 401 ]).to include(response.status)
      end
    end
  end
end
