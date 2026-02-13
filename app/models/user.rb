class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  before_validation :set_email_confirmation_token, on: :create

  def email_confirmed?
    email_confirmed_at.present?
  end

  private

  def set_email_confirmation_token
    self[:email_confirmation_token] ||= SecureRandom.urlsafe_base64(32)
  end
end
