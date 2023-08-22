class CreateContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :contacts do |t|
      t.string :name, null: false
      t.string :relationship, null: false
      t.string :phone, null: false
      t.references :client, foreign_key: true
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
