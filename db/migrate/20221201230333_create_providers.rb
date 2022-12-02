class CreateProviders < ActiveRecord::Migration[5.2]
  def change
    create_table :providers do |t|
      t.string :name, null: false
      t.string :cuit
      t.string :description
      t.string :activity
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
