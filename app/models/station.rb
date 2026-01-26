class Station < ApplicationRecord
  has_many :toilets, dependent: :destroy

  validates :name, presence: true
  validates :operator_name, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true

  validates :name, uniqueness: { scope: :operator_name }
  def display_name
    "#{operator_name} #{name}"
  end
end
