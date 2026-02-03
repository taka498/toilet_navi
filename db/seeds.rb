# db/seeds.rb
Rails.application.eager_load!

if Rails.env.production?
  unless ENV["ALLOW_PROD_SEED"] == "true"
    puts "Skip seeds (production without ALLOW_PROD_SEED)"
    exit
  end
end

puts "=== seed reset ==="

# 破壊的リセット（本番は明示許可がある時だけ）
if Rails.env.production?
  if ENV["ALLOW_PROD_SEED_RESET"] == "true"
    Toilet.delete_all
    Station.delete_all
  else
    puts "Skip destructive reset (set ALLOW_PROD_SEED_RESET=true to delete_all)"
  end
else
  Toilet.delete_all
  Station.delete_all
end

# ---- Station（RESETしない場合も重複しないようにする）----
stations = {
  shinjuku: Station.find_or_create_by!(operator_name: "JR東日本", name: "新宿") do |s|
    s.latitude  = 35.690921
    s.longitude = 139.700258
  end,
  omiya: Station.find_or_create_by!(operator_name: "JR東日本", name: "大宮") do |s|
    s.latitude  = 35.906650
    s.longitude = 139.623260
  end,
  tokyo: Station.find_or_create_by!(operator_name: "東京メトロ", name: "東京") do |s|
    s.latitude  = 35.681236
    s.longitude = 139.767125
  end
}

base_lat = 35.690900
base_lng = 139.700200

toilets = []

10.times do |i|
  toilets << {
    station: stations[:shinjuku],
    name: "新宿テストトイレ#{i + 1}",
    latitude: base_lat + (i * 0.00015),
    longitude: base_lng + (i * 0.00012),
    style_type: (i % 3 == 0 ? "japanese" : i % 3 == 1 ? "western" : "both"),
    has_washlet: (i % 2 == 0),
    is_wheelchair_accessible: (i % 2 == 0),
    is_ostomate_accessible: (i % 3 == 0),
    is_baby_friendly: (i % 4 == 0),
    is_gender_separated: true,
    is_multipurpose: (i % 5 == 0),
    location_note: (i % 3 == 0 ? "改札内・端の方" : nil)
  }
end

toilets << {
  station: stations[:omiya],
  name: "大宮 中央改札内トイレ",
  latitude: 35.906700,
  longitude: 139.623100,
  style_type: "western",
  has_washlet: true,
  is_wheelchair_accessible: true,
  is_ostomate_accessible: false,
  is_baby_friendly: true,
  is_gender_separated: true,
  is_multipurpose: true,
  location_note: "改札内"
}

toilets << {
  station: stations[:tokyo],
  name: "東京 地下通路トイレ",
  latitude: 35.681100,
  longitude: 139.767300,
  style_type: "both",
  has_washlet: false,
  is_wheelchair_accessible: false,
  is_ostomate_accessible: true,
  is_baby_friendly: false,
  is_gender_separated: true,
  is_multipurpose: false,
  location_note: nil
}

# ---- Toilet（RESETしない場合も重複しないようにする）----
toilets.each_with_index do |t, idx|
  station = t.delete(:station)

  toilet = station.toilets.find_or_initialize_by(name: t[:name])
  toilet.assign_attributes(t)

  unless toilet.valid?
    puts "Seed toilet invalid at index=#{idx}: #{t[:name]}"
    puts toilet.errors.full_messages.inspect
    puts "attrs=#{t.inspect}"
    raise "Seed failed"
  end

  toilet.save!
end

puts "Seed done: Station=#{Station.count}, Toilet=#{Toilet.count}"
puts "============================"
