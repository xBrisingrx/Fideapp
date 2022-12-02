class CreatePriceAdjustments < ActiveRecord::Migration[5.2]
  def change
    create_table :price_adjustments do |t|
      t.date :date, null:false
      t.decimal :value, null:false, precision: 15, scale: 2, default: 0
      t.string :comment
      t.boolean :active, default: true
      
      t.timestamps
    end
  end
end
