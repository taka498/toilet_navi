require "rails_helper"

RSpec.describe "Reviews edit", type: :request do
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
    Review.create!(user: user1, toilet: toilet, rating: 5, comment: "とても良い")
  end

  describe "GET /reviews/:id/edit" do
    context "when logged in as review owner" do
      it "renders the edit page" do
        sign_in_as(user1)

        get "/reviews/#{review1.id}/edit", headers: auth_headers("ACCEPT" => "text/html")

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("レビューを編集")
        expect(response.body).to include("Toilet A")
        expect(response.body).to include("評価")
        expect(response.body).to include("コメント")
        expect(response.body).to include("レビューを更新する")
      end
    end

    context "when logged in as another user" do
      it "does not allow access" do
        sign_in_as(user2)

        get "/reviews/#{review1.id}/edit", headers: auth_headers("ACCEPT" => "text/html")

        expect([ 302, 404 ]).to include(response.status)
      end
    end
  end

  describe "PATCH /reviews/:id" do
    context "when logged in as review owner" do
      it "updates the review" do
        sign_in_as(user1)

        patch "/reviews/#{review1.id}",
              params: { review: { rating: 3, comment: "修正後コメント" } },
              headers: auth_headers("ACCEPT" => "text/html")

        expect(response).to redirect_to(reviews_path)

        review1.reload
        expect(review1.rating).to eq(3)
        expect(review1.comment).to eq("修正後コメント")
      end
    end

    context "when logged in as another user" do
      it "does not update the review" do
        sign_in_as(user2)

        patch "/reviews/#{review1.id}",
              params: { review: { rating: 1, comment: "勝手に変更" } },
              headers: auth_headers("ACCEPT" => "text/html")

        expect([ 302, 404 ]).to include(response.status)

        review1.reload
        expect(review1.rating).to eq(5)
        expect(review1.comment).to eq("とても良い")
      end
    end
  end
end
