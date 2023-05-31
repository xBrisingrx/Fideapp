class AddRefinancedtoSales < ActiveRecord::Migration[5.2]
  def change
    add_column :sales, :refinanced, :boolean, default: false
  end
end
