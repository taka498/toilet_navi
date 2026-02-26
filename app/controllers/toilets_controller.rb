require "set"

class ToiletsController < ApplicationController
  def index
    toilets = Toilet.includes(:station).order(:id)
    render json: build_payload(toilets), status: :ok
  end

  def show
    toilet = Toilet.includes(:station).find(params[:id])

    favorited =
      if current_user
        current_user.favorites.exists?(toilet_id: toilet.id)
      else
        false
      end

    render json: {
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
      }
    }, status: :ok
  end

  private

  def build_payload(toilets)
    favorited_ids =
      if current_user
        current_user.favorites.pluck(:toilet_id).to_set
      else
        Set.new
      end

    toilets.map do |toilet|
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
        favorited: favorited_ids.include?(toilet.id),
        station: {
          id: toilet.station&.id,
          name: toilet.station&.name,
          operator_name: toilet.station&.operator_name
        }
      }
    end
  end
end
