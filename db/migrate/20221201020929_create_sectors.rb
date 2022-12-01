class CreateSectors < ActiveRecord::Migration[5.2]
  def change
    create_table :sectors do |t|
      t.string :name, null: false
      t.boolean :active, null: false, default: true
      t.decimal :size, null: false, default: 0
      t.references :urbanization, foreign_key: true

      t.timestamps
    end
  end
end
