class CreateApples < ActiveRecord::Migration[5.2]
  def change
    create_table :apples do |t|
      t.string :code, null:false, limit: 100
      t.decimal :hectares, null: false, precision: 15, scale: 2, default: 0.0
      t.decimal :value, null: false, precision: 15, scale: 2, default: 0.0
      t.decimal :space_not_available ,precision: 15, scale: 2, default: 0.0, comment: 'Espacio de la manzana que no puede ser utilizado'
      t.references :condominium, foreign_key: true
      t.references :sector, foreign_key: true
      t.boolean :active, null:false, default: true

      t.timestamps
    end
  end
end
