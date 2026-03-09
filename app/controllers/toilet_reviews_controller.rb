class ToiletReviewsController < ApplicationController
  def create
    toilet = Toilet.find(params[:toilet_id])
    review = current_user.reviews.build(review_params)
    review.toilet = toilet

    if review.save
      render json: {
        id: review.id,
        rating: review.rating,
        comment: review.comment.to_s
      }, status: :created
    else
      render json: {
        errors: review.errors.full_messages
      }, status: :unprocessable_content
    end
  end

  private

  def review_params
    params.require(:review).permit(:rating, :comment)
  end
end
