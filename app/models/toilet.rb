class Toilet < ApplicationRecord
  belongs_to :station

  enum :style_type, { japanese: 0, western: 1, both: 2 }

  validates :name, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true
end
