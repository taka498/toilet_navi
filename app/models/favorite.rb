class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :toilet

  validates :user_id, uniqueness: { scope: :toilet_id }
end
