class CreatePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :payments do |t|
      t.references :sale, foreign_key: true
      t.date :date, null:false
      t.references :payments_currency, foreign_key: true
      t.decimal :payment, null:false
      t.decimal :taken_in, default: 1,  precision: 15, scale: 2, comment: 'A que valor en $ se tomo la moneda'
      t.decimal :total, precision: 15, scale: 2, comment: 'Calculo del valor pagado en $'
      t.boolean :first_pay, default: false, comment: 'Si pertenece a la primer entrega'
      t.text :comment
      t.boolean :active,default: true

      t.timestamps
    end
  end
end
