class CreatePaymentPlans < ActiveRecord::Migration[5.2]
  def change
    create_table :payment_plans do |t|
      t.references :project, foreign_key: true
      t.integer :number, null:false
      t.integer :option, null:false
      t.integer :category, null:false
      t.decimal :price, precision: 15, scale: 2, null:false
      t.date :date, null:false

      t.timestamps
    end
  end
end
