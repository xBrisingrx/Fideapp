class CreateProjectProviders < ActiveRecord::Migration[5.2]
  def change
    create_table :project_providers do |t|
      t.references :project, foreign_key: true
      t.references :provider, foreign_key: true
      t.references :payment_method, foreign_key: true
      t.references :provider_role, foreign_key: true
      t.string :type_total, comment: 'El proveedor puede calcular su precio por el subtotal de la obra o por el precio valor inicial de la obra'
      t.decimal :porcent,precision: 15, scale: 2, default: 0.0, comment: '% que cobra'
      t.decimal :iva,precision: 15, scale: 2, default: 0.0 
      t.decimal :value_iva,precision: 15, scale: 2, default: 0.0, comment: "El valor en pesos del IVA"
      t.decimal :price,precision: 15, scale: 2, default: 0.0, comment: 'Precio que cobra'
      t.decimal :price_calculate,precision: 15, scale: 2, default: 0.0, comment: 'Precio calculado cuando el proveedor cobra por porcentaje de obra'
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
