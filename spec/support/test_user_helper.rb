# spec/support/test_user_helper.rb
module TestUserHelper
  def create_test_user(email: nil, password: "Password1!", confirmed: true)
    email ||= "user-#{SecureRandom.hex(6)}@example.com"

    user = User.new(
      email_address: email,
      password: password,
      password_confirmation: password
    )

    user.email_confirmed_at = Time.current if confirmed && user.respond_to?(:email_confirmed_at=)

    user.save!
    user
  end
end
