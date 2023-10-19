class AddDefaultValueToLandProjectsStatus < ActiveRecord::Migration[5.2]
  def change
    change_column :land_projects, :status, :integer, default: 1
  end
end
