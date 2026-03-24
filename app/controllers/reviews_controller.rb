class ReviewsController < ApplicationController
  before_action :set_review, only: [ :edit, :update, :destroy ]

  def index
    @reviews = current_user.reviews
      .includes(toilet: :station)
      .order(created_at: :desc)
  end

  def edit
  end

  def update
    if @review.update(review_params)
      redirect_to reviews_path, notice: "レビューを更新しました"
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @review.destroy
    redirect_to reviews_path, notice: "レビューを削除しました"
  end

  private

  def set_review
    @review = current_user.reviews.includes(toilet: :station).find(params[:id])
  end

  def review_params
    params.require(:review).permit(:rating, :comment)
  end
end
