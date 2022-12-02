class CreateLandProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :land_projects do |t|
      t.references :land, foreign_key: true
      t.references :project, foreign_key: true
      t.string :status
      t.decimal :price,:porcent,precision: 15, scale: 2, default: 0.0
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
