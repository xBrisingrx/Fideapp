class CreateProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :projects do |t|
      t.integer :number, null: false
      t.string :name
      t.boolean :active
      t.decimal :price, precision: 15, scale: 2, default: 0, null: false
      t.decimal :final_price, precision: 15, scale: 2, default: 0, null: false
      t.integer :status, default: 0
      t.text :description
      t.decimal :land_price, precision: 15, scale: 2, default: 0, null: false, comment: 'Precio por lote'
      t.decimal :land_corner_price, precision: 15, scale: 2, default: 0, null: false, comment: 'Precio por lote que es esquina'
      t.references :project_type, foreign_key: true
      t.boolean :active, default: true
      t.timestamps
    end
  end
end
