class FixToiletsConstraints < ActiveRecord::Migration[8.0]
  def up
    # 既存NULLを埋める（NOT NULL化で失敗しないため）
    execute <<~SQL
      UPDATE toilets SET is_wheelchair_accessible = FALSE WHERE is_wheelchair_accessible IS NULL;
      UPDATE toilets SET is_ostomate_accessible   = FALSE WHERE is_ostomate_accessible   IS NULL;
      UPDATE toilets SET is_baby_friendly         = FALSE WHERE is_baby_friendly         IS NULL;
      UPDATE toilets SET is_gender_separated      = FALSE WHERE is_gender_separated      IS NULL;
      UPDATE toilets SET is_multipurpose          = FALSE WHERE is_multipurpose          IS NULL;
      UPDATE toilets SET style_type               = 2     WHERE style_type               IS NULL;
    SQL

    # DEFAULT（DB側に固定）
    change_column_default :toilets, :is_wheelchair_accessible, from: nil, to: false
    change_column_default :toilets, :is_ostomate_accessible,   from: nil, to: false
    change_column_default :toilets, :is_baby_friendly,         from: nil, to: false
    change_column_default :toilets, :is_gender_separated,      from: nil, to: false
    change_column_default :toilets, :is_multipurpose,          from: nil, to: false
    # style_type は既に default 2 が入ってるなら from: nil を外してもOK（厳密に行くなら後述）
    change_column_default :toilets, :style_type, to: 2

    # NOT NULL（DB側に固定）
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

  def down
    change_column_null :toilets, :style_type, true
    change_column_default :toilets, :style_type, from: 2, to: nil

    %i[
      is_wheelchair_accessible
      is_ostomate_accessible
      is_baby_friendly
      is_gender_separated
      is_multipurpose
    ].each do |col|
      change_column_null :toilets, col, true
      change_column_default :toilets, col, from: false, to: nil
    end

    change_column_null :toilets, :longitude, true
    change_column_null :toilets, :latitude,  true
    change_column_null :toilets, :name,      true
  end
end
