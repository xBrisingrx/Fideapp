class CreateFees < ActiveRecord::Migration[5.2]
  def change
    create_table :fees do |t|
      t.date :due_date
      t.decimal :interest, null:false, precision: 15, scale: 2, default: 0, comment: 'Interes'
      t.integer :number, null: false
      t.decimal :owes, null:false, precision: 15, scale: 2, default: 0, comment: 'Lo que adeuda'
      t.date :pay_date
      t.boolean :payed, default: false
      t.decimal :payment, null:false, precision: 15, scale: 2, default: 0, comment: 'Valor pagado'
      t.decimal :total_value, null:false, precision: 15, scale: 2, default: 0, comment: 'Valor inicial + ajustes + intereses'
      t.decimal :value, null:false, precision: 15, scale: 2, default: 0, comment: 'Valor inicial'
      t.string :comment, default: ''
      t.integer :pay_status,  default: 0
      t.references :sale, foreign_key: true
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
