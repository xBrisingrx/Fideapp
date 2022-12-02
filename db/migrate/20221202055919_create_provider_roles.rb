class CreateProviderRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :provider_roles do |t|
      t.string :name, null: false
      t.string :description
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
