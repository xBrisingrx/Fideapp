class CreateProviders < ActiveRecord::Migration[5.2]
  def change
    create_table :providers do |t|
      t.string :name
      t.string :cuit
      t.string :description
      t.string :activity
      t.boolean :active

      t.timestamps
    end
  end
end
