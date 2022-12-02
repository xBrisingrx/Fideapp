class CreateProjectMaterials < ActiveRecord::Migration[5.2]
  def change
    create_table :project_materials do |t|
      t.references :project, foreign_key: true
      t.references :material, foreign_key: true
      t.boolean :active, default: true
      t.decimal :price,:porcent,precision: 15, scale: 2, default: 0.0
      t.decimal :units,:porcent,precision: 15, scale: 2, default: 0.0
      t.string :type_units, null: false

      t.timestamps
    end
  end
end
