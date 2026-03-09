class ReviewsController < ApplicationController
  def index
    @reviews = current_user.reviews
      .includes(toilet: :station)
      .order(created_at: :desc)
  end
end
