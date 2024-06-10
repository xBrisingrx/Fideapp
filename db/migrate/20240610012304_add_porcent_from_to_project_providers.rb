class AddPorcentFromToProjectProviders < ActiveRecord::Migration[5.2]
  def change
    add_column :project_providers, :porcent_from, :string
  end
end
