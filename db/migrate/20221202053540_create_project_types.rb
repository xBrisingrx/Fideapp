class CreateProjectTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :project_types do |t|
      t.string :name, null: false
      t.string :description, default: ''
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
