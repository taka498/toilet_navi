class UserMailer < ApplicationMailer
  def email_confirmation(user)
    @user = user
    mail to: @user.email_address, subject: "【Toilet Navi】メールアドレス確認"
  end
end
