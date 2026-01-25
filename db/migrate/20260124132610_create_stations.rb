class CreateStations < ActiveRecord::Migration[8.0]
  def change
    create_table :stations do |t|
      t.string :name
      t.string :operator_name
      t.decimal :latitude
      t.decimal :longitude

      t.timestamps
    end
  end
end
