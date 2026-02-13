class EmailConfirmationsController < ApplicationController
  allow_unauthenticated_access only: %i[show]

  def show
    user = User.find_by(email_confirmation_token: params[:token])
    if user.nil?
      redirect_to root_path, alert: "確認リンクが無効です"
      return
    end

    user.update!(email_confirmed_at: Time.current, email_confirmation_token: nil)
    redirect_to new_session_path, notice: "メール確認が完了しました。ログインしてください。"
  end
end
