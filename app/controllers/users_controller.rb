class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[new create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      Rails.logger.info("[signup] user_id=#{@user.id} email=#{@user.email_address} token=#{@user.email_confirmation_token.inspect}")

      UserMailer.email_confirmation(@user).deliver_now
      
      redirect_to new_session_path, notice: "確認メールを送信しました。メール内リンクから確認してください。"
    else
      render :new, status: :unprocessable_entity
    end

  end

  private

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation)
  end
end
