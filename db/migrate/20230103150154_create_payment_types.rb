class CreatePaymentTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :payment_types do |t|
      t.string :name
      t.string :description
      t.boolean :active

      t.timestamps
    end
  end
end
