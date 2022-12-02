class CreateAdjusts < ActiveRecord::Migration[5.2]
  def change
    create_table :adjusts do |t|
      t.decimal :value,:porcent,precision: 15, scale: 2, default: 0.0
      t.boolean :active, default: true
      t.string :comment
      t.references :fee, foreign_key: true

      t.timestamps
    end
  end
end
