# spec/models/user_spec.rb
require "rails_helper"

RSpec.describe User, type: :model do
  describe "email normalization" do
    it "normalizes email_address (strip + downcase) on create" do
      raw_email = " Test+#{SecureRandom.hex(4)}@Example.COM "
      expected_email = raw_email.strip.downcase

      user = User.create!(
        email_address: raw_email,
        password: "password"
      )

      expect(user.email_address).to eq(expected_email)
    end
  end

  describe "email confirmation token" do
    it "sets email_confirmation_token on create" do
      user = User.create!(
        email_address: "test+#{SecureRandom.hex(4)}@example.com",
        password: "password"
      )

      expect(user.email_confirmation_token).to be_present
    end

    it "does not overwrite email_confirmation_token if already set" do
      token = "fixed-token"

      user = User.create!(
        email_address: "test+#{SecureRandom.hex(4)}@example.com",
        password: "password",
        email_confirmation_token: token
      )

      expect(user.email_confirmation_token).to eq(token)
    end
  end
end
