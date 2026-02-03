class AddHasWashletToToilets < ActiveRecord::Migration[8.0]
  def change
    add_column :toilets, :has_washlet, :boolean
  end
end
