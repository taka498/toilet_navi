require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "#email_confirmation" do
    it "件名と宛先が正しい" do
      user = User.create!(
        email_address: "mail@example.com",
        password: "password123",
        password_confirmation: "password123"
      )

      mail = UserMailer.email_confirmation(user)

      expect(mail.to).to eq([ user.email_address ])
      expect(mail.subject).to eq("【Toilet Navi】メールアドレス確認")
    end

    it "本文に確認リンクが含まれる" do
      user = User.create!(
        email_address: "mail2@example.com",
        password: "password123",
        password_confirmation: "password123"
      )

      mail = UserMailer.email_confirmation(user)

      html = mail.html_part&.body&.decoded
      expect(html).to include("/email/confirm?token=")
    end
  end
end
