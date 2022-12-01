class CreateClients < ActiveRecord::Migration[5.2]
  def change
    create_table :clients do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.string :last_name, null: false
      t.string :dni, limit:20
      t.string :email, limit: 100
      t.string :direction
      t.string :marital_status, limit: 30
      t.string :phone, limit: 20
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
