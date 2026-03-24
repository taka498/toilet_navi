class ToiletReviewsController < ApplicationController
  allow_unauthenticated_access only: [ :index ]

  def index
    @toilet = Toilet.includes(:station, reviews: :user).find(params[:toilet_id])
    @reviews = @toilet.reviews.includes(:user).order(created_at: :desc)

    @average_rating =
      if @reviews.any?
        @reviews.average(:rating).to_f.round(1)
      end
  end

  def new
    @toilet = Toilet.includes(:station).find(params[:toilet_id])

    existing_review = current_user.reviews.find_by(toilet: @toilet)
    if existing_review
      redirect_to reviews_path, alert: "このトイレにはすでにレビューを投稿しています"
      return
    end

    @review = current_user.reviews.build(toilet: @toilet)
  end

  def create
    @toilet = Toilet.find(params[:toilet_id])
    @review = current_user.reviews.build(review_params)
    @review.toilet = @toilet

    respond_to do |format|
      if @review.save
        format.html { redirect_to reviews_path, notice: "レビューを投稿しました" }
        format.json do
          render json: {
            id: @review.id,
            rating: @review.rating,
            comment: @review.comment.to_s
          }, status: :created
        end
      else
        format.html { render :new, status: :unprocessable_content }
        format.json do
          render json: {
            errors: @review.errors.full_messages
          }, status: :unprocessable_content
        end
      end
    end
  end

  private

  def review_params
    params.require(:review).permit(:rating, :comment)
  end
end
