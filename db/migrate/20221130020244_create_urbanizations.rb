class CreateUrbanizations < ActiveRecord::Migration[5.2]
  def change
    create_table :urbanizations do |t|
      t.string :name, null: false
      t.boolean :active, null: false, default: true
      t.decimal :size, default: 0

      t.timestamps
    end
  end
end
