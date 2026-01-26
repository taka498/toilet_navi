class FixStationsConstraints < ActiveRecord::Migration[8.0]
  def up
    # --- 1) 既存データの NULL を埋める ---
    # （理由）NOT NULL 制約を付ける前に、DBエラーを防ぐため
    execute <<~SQL
      UPDATE stations SET operator_name = '不明' WHERE operator_name IS NULL;
      UPDATE stations SET name = '不明' WHERE name IS NULL;
    SQL

    # 緯度経度は仮値を入れず、もし NULL があれば明示的にエラーにした方が安全
    # → ここでは NULL のまま残し、NOT NULL で migrate を落とす（問題の早期発見）

    # --- 2) NOT NULL 制約 ---
    change_column_null :stations, :operator_name, false
    change_column_null :stations, :name, false
    change_column_null :stations, :latitude, false
    change_column_null :stations, :longitude, false

    # --- 3) 重複防止（operator_name + name をユニーク） ---
    add_index :stations, [:operator_name, :name], unique: true
  end

  def down
    remove_index :stations, column: [:operator_name, :name]

    change_column_null :stations, :longitude, true
    change_column_null :stations, :latitude, true
    change_column_null :stations, :name, true
    change_column_null :stations, :operator_name, true
  end
end
