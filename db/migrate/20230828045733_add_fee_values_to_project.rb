class AddFeeValuesToProject < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :price_fee, :decimal,precision: 15, scale: 2, null: false ,comment: "Valor de la cuota del proyecto"
    add_column :projects, :price_fee_corner, :decimal,precision: 15, scale: 2, null: false ,comment: "Valor de la cuota del proyecto para esquinas"
  end
end
