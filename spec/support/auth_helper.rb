# spec/support/auth_helper.rb
module AuthHelpers
  def sign_in_as(user)
    session = Session.create!(user: user)

    signed = sign_cookie_value(session.id)

    # request spec では Cookie ヘッダで渡す
    @auth_cookie_header = "session_id=#{Rack::Utils.escape(signed)}"

    session
  end

  def auth_headers(extra = {})
    base = @auth_cookie_header ? { "Cookie" => @auth_cookie_header } : {}
    base.merge(extra)
  end

  private

  def sign_cookie_value(value)
    salt = Rails.application.config.action_dispatch.signed_cookie_salt
    secret = Rails.application.key_generator.generate_key(salt)

    # ✅ digest を固定しない（Railsのデフォルト/設定に追従）
    ActiveSupport::MessageVerifier.new(
      secret,
      serializer: cookie_serializer
    ).generate(value)
  end

  def cookie_serializer
    # ✅ ActionDispatch::Cookies::Serializer に依存しない
    case Rails.application.config.action_dispatch.cookies_serializer
    when :json
      JSON
    when :hybrid
      JSON
    else
      Marshal
    end
  end
end
