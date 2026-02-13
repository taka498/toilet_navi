require "rails_helper"

RSpec.describe "Pages", type: :request do
  it "トップページが表示される" do
    get "/"
    expect(response).to have_http_status(:ok)
  end

  it "利用規約が表示される" do
    get "/terms"
    expect(response).to have_http_status(:ok)
  end

  it "プライバシーポリシーが表示される" do
    get "/privacy"
    expect(response).to have_http_status(:ok)
  end

  it "お問い合わせが表示される" do
    get "/contact"
    expect(response).to have_http_status(:ok)
  end
end
