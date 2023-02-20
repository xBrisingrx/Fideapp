class ChangeIntegerToFloarArrearInSalesTable < ActiveRecord::Migration[5.2]
  def change
    change_column :sales, :arrear, :decimal
  end
end
