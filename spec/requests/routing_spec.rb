require "rails_helper"

RSpec.describe "Routing", type: :request do
  it "存在しないページは404になる" do
    get "/this-path-does-not-exist"
    expect(response).to have_http_status(:not_found)
  end
end
