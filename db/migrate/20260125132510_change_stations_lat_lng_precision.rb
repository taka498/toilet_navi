class ChangeStationsLatLngPrecision < ActiveRecord::Migration[8.0]
  def change
    change_column :stations, :latitude,  :decimal, precision: 10, scale: 7
    change_column :stations, :longitude, :decimal, precision: 10, scale: 7
  end
end
