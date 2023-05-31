class AddDateToAdjusts < ActiveRecord::Migration[5.2]
  def change
    add_column :adjusts, :date, :date
  end
end
