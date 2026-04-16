class Review < ApplicationRecord
  belongs_to :user
  belongs_to :toilet

  has_one_attached :image

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :comment, length: { maximum: 500 }, allow_blank: true
  validates :user_id, uniqueness: { scope: :toilet_id }

  validate :image_must_be_valid

  private

  def image_must_be_valid
    return unless image.attached?

    unless image.content_type.in?(%w[image/png image/jpeg image/jpg image/webp])
      errors.add(:image, "は PNG / JPG / WEBP を選択してください")
    end

    if image.blob.byte_size > 5.megabytes
      errors.add(:image, "は 5MB 以下にしてください")
    end
  end
end
