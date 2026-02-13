class TestMailer < ApplicationMailer
  def ping
    mail(to: "test@example.com", subject: "MailHog ping")
  end
end
