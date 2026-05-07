class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[new create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      @user.update_column(:email_confirmed_at, Time.current)
      start_new_session_for(@user)

      redirect_to after_authentication_url, notice: "ユーザー登録が完了しました。"
    else
      flash.now[:alert] = "登録できませんでした。入力内容をご確認ください。"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation)
  end
end
