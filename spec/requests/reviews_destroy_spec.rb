require "rails_helper"

RSpec.describe "Reviews destroy", type: :request do
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

  let!(:toilet) do
    Toilet.create!(
      station: station,
      name: "Toilet A",
      latitude: 35.0,
      longitude: 139.0
    )
  end

  let!(:review1) do
    Review.create!(
      user: user1,
      toilet: toilet,
      rating: 5,
      comment: "とても良い"
    )
  end

  describe "DELETE /reviews/:id" do
    context "when owner deletes review" do
      it "removes the review" do
        sign_in_as(user1)

        expect {
          delete "/reviews/#{review1.id}",
                 headers: auth_headers("ACCEPT" => "text/html")
        }.to change { Review.count }.by(-1)

        expect(response).to redirect_to(reviews_path)
        expect(response).to have_http_status(:found)
      end
    end

    context "when another user tries to delete" do
      it "does not delete review" do
        sign_in_as(user2)

        expect {
          delete "/reviews/#{review1.id}",
                 headers: auth_headers("ACCEPT" => "text/html")
        }.not_to change { Review.count }

        expect([ 302, 403, 404 ]).to include(response.status)
      end
    end
  end
end
