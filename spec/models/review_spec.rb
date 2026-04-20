require "rails_helper"

RSpec.describe Review, type: :model do
  let!(:user) do
    User.create!(
      email_address: "test+#{SecureRandom.hex(4)}@example.com",
      password: "password"
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

  it "is valid with rating only" do
    review = Review.new(user: user, toilet: toilet, rating: 4, comment: "")
    expect(review).to be_valid
  end

  it "is invalid without rating" do
    review = Review.new(user: user, toilet: toilet, rating: nil, comment: "good")
    expect(review).not_to be_valid
    expect(review.errors[:rating]).to be_present
  end

  it "is invalid when rating is outside 1..5" do
    review = Review.new(user: user, toilet: toilet, rating: 6, comment: "good")
    expect(review).not_to be_valid
    expect(review.errors[:rating]).to be_present
  end

  it "is invalid when the same user reviews the same toilet twice" do
    Review.create!(user: user, toilet: toilet, rating: 5, comment: "great")

    duplicate_review = Review.new(user: user, toilet: toilet, rating: 4, comment: "good")
    expect(duplicate_review).not_to be_valid
    expect(duplicate_review.errors[:user_id]).to be_present
  end

  it "is invalid when comment is too long" do
    review = Review.new(user: user, toilet: toilet, rating: 3, comment: "a" * 501)
    expect(review).not_to be_valid
    expect(review.errors[:comment]).to be_present
  end

  it "is invalid when comment includes ng words" do
    review = Review.new(user: user, toilet: toilet, rating: 3, comment: "このトイレはばか")
    expect(review).not_to be_valid
    expect(review.errors[:comment]).to include("に不適切な表現が含まれています")
  end

  it "is valid when comment does not include ng words" do
    review = Review.new(user: user, toilet: toilet, rating: 3, comment: "清掃されていて使いやすかったです")
    expect(review).to be_valid
  end
end
