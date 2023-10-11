class ChangeStatusTypeToSales < ActiveRecord::Migration[5.2]
  def up
    change_column :sales, :status, :integer
  end

  def down
    change_column :sales, :status, :integer
  end
end
