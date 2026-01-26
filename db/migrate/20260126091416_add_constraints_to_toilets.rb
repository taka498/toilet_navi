class AddConstraintsToToilets < ActiveRecord::Migration[8.0]
  def change
    # まずは既存データが nil の場合に備えて埋める（将来の事故防止）
    change_column_default :toilets, :is_wheelchair_accessible, from: nil, to: false
    change_column_default :toilets, :is_ostomate_accessible,   from: nil, to: false
    change_column_default :toilets, :is_baby_friendly,         from: nil, to: false
    change_column_default :toilets, :is_gender_separated,      from: nil, to: false
    change_column_default :toilets, :is_multipurpose,          from: nil, to: false

    # style_type は enum なので default を入れておく（both=2 の想定）
    change_column_default :toilets, :style_type, from: nil, to: 2

    # nil を禁止（MVPの地図表示に必須）
    change_column_null :toilets, :name,      false
    change_column_null :toilets, :latitude,  false
    change_column_null :toilets, :longitude, false

    change_column_null :toilets, :is_wheelchair_accessible, false
    change_column_null :toilets, :is_ostomate_accessible,   false
    change_column_null :toilets, :is_baby_friendly,         false
    change_column_null :toilets, :is_gender_separated,      false
    change_column_null :toilets, :is_multipurpose,          false

    change_column_null :toilets, :style_type, false
  end
end
