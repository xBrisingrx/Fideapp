class RemoveArrearToSales < ActiveRecord::Migration[5.2]
  def change
    remove_column :sales, :apply_arrear
    remove_column :sales, :arrear
  end
end
