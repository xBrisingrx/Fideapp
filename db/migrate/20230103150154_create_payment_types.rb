class CreatePaymentTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :payments_types do |t|
      t.string :name
      t.string :description
      t.boolean :active, default:true

      t.timestamps
    end
  end
end
