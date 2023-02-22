class ChangeIntegerToFloarArrearInSalesTable < ActiveRecord::Migration[5.2]
  def up
    change_column :sales, :arrear, :decimal,precision: 15, scale: 2, default: 0.5
  end

  def down
    change_column :sales, :arrear, :integer
  end
end
