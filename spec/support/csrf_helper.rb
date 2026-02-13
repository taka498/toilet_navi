module CsrfHelper
  def csrf_token_from(html)
    # layoutの meta から取る（最優先）
    token = html[/<meta name="csrf-token" content="([^"]+)"\/?>/i, 1]
    return token if token

    # formの hidden field から取る（保険）
    html[/name="authenticity_token" value="([^"]+)"/i, 1]
  end

  def get_csrf_token(path = "/")
    get path
    token = csrf_token_from(response.body)
    raise "CSRF token not found in response body for GET #{path}" unless token
    token
  end
end

RSpec.configure do |config|
  config.include CsrfHelper, type: :request
end
