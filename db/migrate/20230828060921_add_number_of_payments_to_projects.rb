class AddNumberOfPaymentsToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :number_of_payments, :integer, null: false
  end
end
