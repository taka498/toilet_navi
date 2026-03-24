class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  has_many :favorites, dependent: :destroy
  has_many :favorite_toilets, through: :favorites, source: :toilet

  has_many :reviews, dependent: :destroy
  has_many :reviewed_toilets, through: :reviews, source: :toilet

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  before_create :set_email_confirmation_token

  validates :display_name, length: { maximum: 30 }, allow_blank: true

  def email_confirmed?
    email_confirmed_at.present?
  end

  private

  def set_email_confirmation_token
    self.email_confirmation_token ||= SecureRandom.urlsafe_base64(32)
  end
end
