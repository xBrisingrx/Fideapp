class RemoveFeeAttributesToProject < ActiveRecord::Migration[5.2]
  def change
    remove_column :projects, :price_fee
    remove_column :projects, :price_fee_corner
    remove_column :projects, :number_of_payments
  end
end
