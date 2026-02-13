require "rails_helper"

RSpec.describe "Search", type: :request do
  it "検索ページが表示される" do
    get "/search"
    expect(response).to have_http_status(:ok)
  end
end
