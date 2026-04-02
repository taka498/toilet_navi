require "rails_helper"

RSpec.describe "Toilets", type: :request do
  let!(:station) do
    Station.create!(
      name: "Station A",
      operator_name: "Operator A",
      latitude: 35.681236,
      longitude: 139.767125
    )
  end

  let!(:toilet1) do
    Toilet.create!(
      station: station,
      name: "Multipurpose Toilet",
      latitude: 35.0,
      longitude: 139.0,
      style_type: :western,
      has_washlet: true,
      is_multipurpose: true,
      is_wheelchair_accessible: false,
      is_baby_friendly: false,
      is_ostomate_accessible: false
    )
  end

  let!(:toilet2) do
    Toilet.create!(
      station: station,
      name: "Wheelchair Toilet",
      latitude: 35.1,
      longitude: 139.1,
      style_type: :japanese,
      has_washlet: false,
      is_multipurpose: false,
      is_wheelchair_accessible: true,
      is_baby_friendly: false,
      is_ostomate_accessible: true
    )
  end

    let!(:toilet3) do
    Toilet.create!(
      station: station,
      name: "Baby Friendly Toilet",
      latitude: 35.2,
      longitude: 139.2,
      style_type: :both,
      has_washlet: true,
      is_multipurpose: false,
      is_wheelchair_accessible: false,
      is_baby_friendly: true,
      is_ostomate_accessible: false
    )
  end

    let!(:toilet4) do
    Toilet.create!(
      station: station,
      name: "All Conditions Toilet",
      latitude: 35.3,
      longitude: 139.3,
      style_type: :western,
      has_washlet: true,
      is_multipurpose: true,
      is_wheelchair_accessible: true,
      is_baby_friendly: true,
      is_ostomate_accessible: true
    )
  end

  describe "GET /toilets.json" do
    it "returns all toilets when no filters are given" do
      get "/toilets.json", headers: { "ACCEPT" => "application/json" }

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      names = json.map { |toilet| toilet["name"] }

      expect(names).to include(
        "Multipurpose Toilet",
        "Wheelchair Toilet",
        "Baby Friendly Toilet",
        "All Conditions Toilet"
      )
    end

    it "filters by multipurpose" do
      get "/toilets.json",
        params: { multipurpose: "1" },
        headers: { "ACCEPT" => "application/json" }

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      names = json.map { |toilet| toilet["name"] }

      expect(names).to include("Multipurpose Toilet", "All Conditions Toilet")
      expect(names).not_to include("Wheelchair Toilet", "Baby Friendly Toilet")
    end

    it "filters by wheelchair accessibility" do
      get "/toilets.json",
        params: { wheelchair_accessible: "1" },
        headers: { "ACCEPT" => "application/json" }

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      names = json.map { |toilet| toilet["name"] }

      expect(names).to include("Wheelchair Toilet", "All Conditions Toilet")
      expect(names).not_to include("Multipurpose Toilet", "Baby Friendly Toilet")
    end

    it "filters by baby friendly" do
      get "/toilets.json",
        params: { baby_friendly: "1" },
        headers: { "ACCEPT" => "application/json" }

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      names = json.map { |toilet| toilet["name"] }

      expect(names).to include("Baby Friendly Toilet", "All Conditions Toilet")
      expect(names).not_to include("Multipurpose Toilet", "Wheelchair Toilet")
    end

    it "filters by ostomate accessibility" do
      get "/toilets.json",
        params: { ostomate_accessible: "1" },
        headers: { "ACCEPT" => "application/json" }

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      names = json.map { |toilet| toilet["name"] }

      expect(names).to include("Wheelchair Toilet", "All Conditions Toilet")
      expect(names).not_to include("Multipurpose Toilet", "Baby Friendly Toilet")
    end

    it "filters by washlet" do
      get "/toilets.json",
        params: { washlet: "1" },
        headers: { "ACCEPT" => "application/json" }

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      names = json.map { |toilet| toilet["name"] }

      expect(names).to include("Multipurpose Toilet", "Baby Friendly Toilet", "All Conditions Toilet")
      expect(names).not_to include("Wheelchair Toilet")
    end

    it "filters by western style" do
      get "/toilets.json",
        params: { style_type: "western" },
        headers: { "ACCEPT" => "application/json" }

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      names = json.map { |toilet| toilet["name"] }

      expect(names).to include("Multipurpose Toilet", "All Conditions Toilet")
      expect(names).not_to include("Wheelchair Toilet", "Baby Friendly Toilet")
    end

    it "filters by japanese style" do
      get "/toilets.json",
        params: { style_type: "japanese" },
        headers: { "ACCEPT" => "application/json" }

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      names = json.map { |toilet| toilet["name"] }

      expect(names).to include("Wheelchair Toilet")
      expect(names).not_to include("Multipurpose Toilet", "Baby Friendly Toilet", "All Conditions Toilet")
    end

    it "filters by both style" do
      get "/toilets.json",
        params: { style_type: "both" },
        headers: { "ACCEPT" => "application/json" }

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      names = json.map { |toilet| toilet["name"] }

      expect(names).to include("Baby Friendly Toilet")
      expect(names).not_to include("Multipurpose Toilet", "Wheelchair Toilet", "All Conditions Toilet")
    end

    it "applies style_type and washlet filters with AND condition" do
      get "/toilets.json",
        params: {
          style_type: "western",
          washlet: "1"
        },
        headers: { "ACCEPT" => "application/json" }

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      names = json.map { |toilet| toilet["name"] }

      expect(names).to include("Multipurpose Toilet", "All Conditions Toilet")
      expect(names).not_to include("Wheelchair Toilet", "Baby Friendly Toilet")
    end

    it "applies ostomate and wheelchair filters with AND condition" do
      get "/toilets.json",
        params: {
          ostomate_accessible: "1",
          wheelchair_accessible: "1"
        },
        headers: { "ACCEPT" => "application/json" }

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      names = json.map { |toilet| toilet["name"] }

      expect(names).to include("Wheelchair Toilet", "All Conditions Toilet")
      expect(names).not_to include("Multipurpose Toilet", "Baby Friendly Toilet")
    end

    it "applies multiple filters with AND condition" do
      get "/toilets.json",
        params: {
          multipurpose: "1",
          wheelchair_accessible: "1",
          baby_friendly: "1"
        },
        headers: { "ACCEPT" => "application/json" }

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      names = json.map { |toilet| toilet["name"] }

      expect(names).to include("All Conditions Toilet")

      json.each do |toilet|
        expect(toilet["is_multipurpose"]).to eq(true)
        expect(toilet["is_wheelchair_accessible"]).to eq(true)
        expect(toilet["is_baby_friendly"]).to eq(true)
      end
    end
  end
end
