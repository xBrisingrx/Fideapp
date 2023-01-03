class CreatePaymentsCurrencies < ActiveRecord::Migration[5.2]
  def change
    create_table :payments_currencies do |t|
      t.references :payment_type, foreign_key: true
      t.references :currency, foreign_key: true
      t.boolean :active

      t.timestamps
    end
  end
end
