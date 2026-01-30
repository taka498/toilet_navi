Station.where(operator_name: "JR東日本", name: "大宮駅").destroy_all

station = Station.create!(
  name: "大宮駅",
  operator_name: "JR東日本",
  latitude: 35.9066,
  longitude: 139.6231
)

Toilet.where(station: station).destroy_all

Toilet.create!(
  station: station,
  name: "テストトイレ",
  latitude: 35.9069,
  longitude: 139.6234,
  is_wheelchair_accessible: true,
  is_baby_friendly: true,
  is_ostomate_accessible: false,
  is_gender_separated: false,
  is_multipurpose: false,
  style_type: 2
)
