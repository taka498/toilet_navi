class Toilet < ApplicationRecord
  belongs_to :station

  has_many :favorites, dependent: :destroy
  has_many :favorited_users, through: :favorites, source: :user

  has_many :reviews, dependent: :destroy
  has_many :reviewing_users, through: :reviews, source: :user

  enum :style_type, { japanese: 0, western: 1, both: 2 }

  validates :name, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true
end
