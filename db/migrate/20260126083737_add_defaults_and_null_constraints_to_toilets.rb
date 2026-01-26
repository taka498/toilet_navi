class AddDefaultsAndNullConstraintsToToilets < ActiveRecord::Migration[8.0]
  def change
    # boolean は nil を許すと表示側が面倒なので、false で統一する
    change_column_default :toilets, :is_wheelchair_accessible, from: nil, to: false
    change_column_default :toilets, :is_ostomate_accessible,   from: nil, to: false
    change_column_default :toilets, :is_baby_friendly,         from: nil, to: false
    change_column_default :toilets, :is_gender_separated,      from: nil, to: false
    change_column_default :toilets, :is_multipurpose,          from: nil, to: false

    # 既存レコードの nil を埋める（既に作ったテストデータがある前提）
    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE toilets
          SET
            is_wheelchair_accessible = COALESCE(is_wheelchair_accessible, FALSE),
            is_ostomate_accessible   = COALESCE(is_ostomate_accessible,   FALSE),
            is_baby_friendly         = COALESCE(is_baby_friendly,         FALSE),
            is_gender_separated      = COALESCE(is_gender_separated,      FALSE),
            is_multipurpose          = COALESCE(is_multipurpose,          FALSE)
        SQL

        # style_type（enum）も nil を許すと扱いづらいので、両方併設(both)をデフォルトにする
        execute <<~SQL
          UPDATE toilets
          SET style_type = COALESCE(style_type, 2)
        SQL
      end
    end

    # null 制約をつける
    change_column_null :toilets, :is_wheelchair_accessible, false
    change_column_null :toilets, :is_ostomate_accessible,   false
    change_column_null :toilets, :is_baby_friendly,         false
    change_column_null :toilets, :is_gender_separated,      false
    change_column_null :toilets, :is_multipurpose,          false

    # enum のデフォルトと null 制約
    change_column_default :toilets, :style_type, from: nil, to: 2
    change_column_null    :toilets, :style_type, false
  end
end
