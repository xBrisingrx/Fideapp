class CreateInterests < ActiveRecord::Migration[5.2]
  def change
    create_table :interests do |t|
      t.date :date, null:false
      t.decimal :value, precision: 15, scale: 2, null:false
      t.references :fee_payment, foreign_key: true
      t.boolean :active, default: true
      
      t.timestamps
    end
  end
end
