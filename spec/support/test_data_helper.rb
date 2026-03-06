# spec/support/test_data_helper.rb
module TestDataHelper
  def create_test_station(name: "Station A", operator_name: "Operator A")
    Station.create!(
      name: name,
      operator_name: operator_name,
      latitude: 35.681236,
      longitude: 139.767125
    )
  end

  def create_test_toilet(station:, name: "Toilet", lat: 35.0, lng: 139.0)
    Toilet.create!(
      station: station,
      name: name,
      latitude: lat,
      longitude: lng
    )
  end
end
