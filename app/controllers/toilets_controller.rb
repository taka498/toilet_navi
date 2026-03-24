require "set"

class ToiletsController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]

  def index
    toilets = Toilet.includes(:station).order(:id)
    render json: build_payload(toilets), status: :ok
  end

  def show
    toilet = Toilet.includes(:station, reviews: :user).find(params[:id])

    render json: build_toilet_json(toilet), status: :ok
  end

  private

  def build_payload(toilets)
    favorited_ids =
      if current_user
        ::Favorite.where(user_id: current_user.id).pluck(:toilet_id).to_set
      else
        Set.new
      end

    toilets.map do |toilet|
      build_toilet_json(toilet, favorited_ids: favorited_ids)
    end
  end

  def build_toilet_json(toilet, favorited_ids: nil)
    favorited =
      if current_user
        if favorited_ids
          favorited_ids.include?(toilet.id)
        else
          ::Favorite.exists?(user_id: current_user.id, toilet_id: toilet.id)
        end
      else
        false
      end

    reviews = toilet.reviews.includes(:user).order(created_at: :desc)

    average_rating =
      if reviews.any?
        reviews.average(:rating).to_f.round(1)
      end

    current_user_review =
      if current_user
        reviews.find { |review| review.user_id == current_user.id }
      end

    {
      id: toilet.id,
      name: toilet.name,
      latitude: toilet.latitude,
      longitude: toilet.longitude,
      style_type: toilet.style_type,
      has_washlet: toilet.has_washlet,
      is_baby_friendly: toilet.is_baby_friendly,
      is_multipurpose: toilet.is_multipurpose,
      is_wheelchair_accessible: toilet.is_wheelchair_accessible,
      is_ostomate_accessible: toilet.is_ostomate_accessible,
      is_gender_separated: toilet.is_gender_separated,
      location_note: toilet.location_note,
      favorited: favorited,
      station: {
        id: toilet.station&.id,
        name: toilet.station&.name,
        operator_name: toilet.station&.operator_name
      },
      review_summary: {
        average_rating: average_rating,
        review_count: reviews.size
      },
      current_user_review: current_user_review ? {
        id: current_user_review.id,
        rating: current_user_review.rating,
        comment: current_user_review.comment.to_s
      } : nil,
      reviews: reviews.map do |review|
        {
          id: review.id,
          rating: review.rating,
          comment: review.comment.to_s,
          created_at: review.created_at,
          user: {
            id: review.user&.id,
            display_name: review.user&.display_name.presence || "no name"
          }
        }
      end
    }
  end
end
