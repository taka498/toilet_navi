class Review < ApplicationRecord
  belongs_to :user
  belongs_to :toilet

  has_one_attached :image

  NG_WORDS = %w[
    ばか
    バカ
    あほ
    アホ
    しね
    死ね
  ].freeze

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :comment, length: { maximum: 500 }, allow_blank: true
  validates :user_id, uniqueness: { scope: :toilet_id }

  validate :image_must_be_valid
  validate :comment_must_not_include_ng_words

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

  def comment_must_not_include_ng_words
    return if comment.blank?

    if NG_WORDS.any? { |word| comment.include?(word) }
      errors.add(:comment, "に不適切な表現が含まれています")
    end
  end
end
