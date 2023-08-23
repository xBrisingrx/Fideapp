class AddDateToProject < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :date, :date, null: false
  end
end
