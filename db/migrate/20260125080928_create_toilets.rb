class CreateToilets < ActiveRecord::Migration[8.0]
  def change
    create_table :toilets do |t|
      t.references :station, null: false, foreign_key: true
      t.string :name
      t.decimal :latitude, precision: 10, scale: 7
      t.decimal :longitude, precision: 10, scale: 7
      t.text :location_note
      t.boolean :is_wheelchair_accessible
      t.boolean :is_ostomate_accessible
      t.boolean :is_baby_friendly
      t.boolean :is_gender_separated
      t.boolean :is_multipurpose
      t.integer :style_type
      t.string :place_id

      t.timestamps
    end
  end
end
