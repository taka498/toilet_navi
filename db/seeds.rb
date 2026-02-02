# db/seeds.rb
Rails.application.eager_load!

unless Rails.env.development?
  puts "Skip seeds (not development)"
  exit
end

puts "=== development seed reset ==="

Toilet.delete_all
Station.delete_all

# ---- Station（stationsもlat/lng必須）----
stations = {
  shinjuku: Station.create!(
    operator_name: "JR東日本",
    name: "新宿",
    latitude: 35.690921,
    longitude: 139.700258
  ),
  omiya: Station.create!(
    operator_name: "JR東日本",
    name: "大宮",
    latitude: 35.906650,
    longitude: 139.623260
  ),
  tokyo: Station.create!(
    operator_name: "東京メトロ",
    name: "東京",
    latitude: 35.681236,
    longitude: 139.767125
  )
}

# ---- Toilet（12件：設備を散らす / スクロール確認用）----
base_lat = 35.690900
base_lng = 139.700200

toilets = []

# 新宿：10件作ってスクロール確認しやすくする
10.times do |i|
  toilets << {
    station: stations[:shinjuku],
    name: "新宿テストトイレ#{i + 1}",
    latitude: base_lat + (i * 0.00015),
    longitude: base_lng + (i * 0.00012),
    style_type: (i % 3 == 0 ? "japanese" : i % 3 == 1 ? "western" : "both"),
    is_wheelchair_accessible: (i % 2 == 0),
    is_ostomate_accessible: (i % 3 == 0),
    is_baby_friendly: (i % 4 == 0),
    is_gender_separated: true,       # 共用は廃止方針とのことなので固定でtrue
    is_multipurpose: (i % 5 == 0),
    location_note: (i % 3 == 0 ? "改札内・端の方" : nil)
  }
end

# 他駅：2件
toilets << {
  station: stations[:omiya],
  name: "大宮 中央改札内トイレ",
  latitude: 35.906700,
  longitude: 139.623100,
  style_type: "western",
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
  is_wheelchair_accessible: false,
  is_ostomate_accessible: true,
  is_baby_friendly: false,
  is_gender_separated: true,
  is_multipurpose: false,
  location_note: nil
}

# 保存（落ちたらどれが原因か出す）
toilets.each_with_index do |t, idx|
  station = t.delete(:station)
  toilet = station.toilets.build(t)

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
