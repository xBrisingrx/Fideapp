class CreateSales < ActiveRecord::Migration[5.2]
  def change
    create_table :sales do |t|
      t.boolean :status, default: 0
      t.boolean :apply_arrear, null:false, default: 0, comment: 'Venta aplica mora'
      t.integer :arrear, null:false, default: 0, comment: '% de mora'
      t.text :comment
      t.date :date, null:false, comment: 'Fecha en que se realizo la venta'
      t.integer :due_day, null: false, default: 10, comment: 'Num dia de vencimiento de pagos'
      t.integer :number_of_payments, null:false, comment: 'Num de cuotas inicial'
      t.decimal :price, null:false, precision: 15, scale: 2, default: 0, comment: 'Valor inicial de venta'
      t.references :land, foreign_key: true
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
