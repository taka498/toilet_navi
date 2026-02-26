class FavoritesController < ApplicationController
  # ★これだけで十分
  before_action :require_authentication

  def index
    @favorites = current_user.favorites
      .includes(toilet: :station)
      .order(created_at: :desc)
  end

  def create
    toilet = Toilet.find(params[:toilet_id])

    current_user.favorites.find_or_create_by!(toilet: toilet)

    render json: { favorited: true }
  end

  def destroy
    toilet = Toilet.find(params[:toilet_id])

    current_user.favorites.where(toilet: toilet).destroy_all

    render json: { favorited: false }
  end
end
