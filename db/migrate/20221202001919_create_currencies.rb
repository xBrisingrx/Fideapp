class CreateCurrencies < ActiveRecord::Migration[5.2]
  def change
    create_table :currencies do |t|
      t.string :name, null: false, limit: 40
      t.string :detail
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
