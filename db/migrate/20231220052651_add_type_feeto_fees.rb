class AddTypeFeetoFees < ActiveRecord::Migration[5.2]
  def change
    add_column :fees, :type_fee, :integer, default: 2
  end
end
