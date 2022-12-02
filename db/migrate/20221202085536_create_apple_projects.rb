class CreateAppleProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :apple_projects do |t|
      t.references :apple, foreign_key: true
      t.references :project, foreign_key: true
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
