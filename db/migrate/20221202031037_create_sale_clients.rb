class CreateSaleClients < ActiveRecord::Migration[5.2]
  def change
    create_table :sale_clients do |t|
      t.references :sale, foreign_key: true
      t.references :client, foreign_key: true
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
