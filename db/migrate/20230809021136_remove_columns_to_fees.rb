class RemoveColumnsToFees < ActiveRecord::Migration[5.2]
  def change
    # Estos valores pasan a ser calculados
    remove_column :fees, :total_value
    remove_column :fees, :owes
  end
end
