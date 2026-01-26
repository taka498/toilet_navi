class TestToiletsDefault < ActiveRecord::Migration[8.0]
  def change
    change_column_default :toilets, :style_type, from: nil, to: 2
  end
end
