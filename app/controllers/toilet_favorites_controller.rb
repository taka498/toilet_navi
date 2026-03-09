class ToiletFavoritesController < ApplicationController
  def create
    toilet = Toilet.find(params[:toilet_id])

    favorite = current_user.favorites.find_or_initialize_by(toilet: toilet)

    if favorite.persisted? || favorite.save
      render json: { favorited: true }, status: :ok
    else
      render json: { errors: favorite.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    toilet = Toilet.find(params[:toilet_id])

    favorite = current_user.favorites.find_by(toilet: toilet)
    favorite&.destroy

    render json: { favorited: false }, status: :ok
  end
end
