class CreateLands < ActiveRecord::Migration[5.2]
  def change
    create_table :lands do |t|
      t.string :code, null: false, comment: 'denominacion'
      t.boolean :is_corner, default: false 
      t.boolean :is_green_space, default: false 
      t.integer :land_type, default: 0
      t.string :measure
      t.decimal :price, precision: 15, scale: 2, default: 0
      t.decimal :space_not_available, precision: 15, scale: 2, default: 0, comment: 'Espacio de el lote que no puede ser utilizado'
      t.integer :status, default: false 
      t.decimal :area, precision: 15, scale: 2, default: 0
      t.string :ubication
      t.references :apple, foreign_key: true
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
