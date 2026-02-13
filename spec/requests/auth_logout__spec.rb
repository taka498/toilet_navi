require "rails_helper"

RSpec.describe "Logout", type: :request do
  it "ログアウトできる" do
    delete "/session"
    expect(response).to have_http_status(:found)
    expect(response).to redirect_to(new_session_path)
  end
end
