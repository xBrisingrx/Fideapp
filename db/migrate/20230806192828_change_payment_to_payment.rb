class ChangePaymentToPayment < ActiveRecord::Migration[5.2]
  def change
    change_column :payments, :payment, :decimal,precision: 15, scale: 2, default: 0.5
  end
end
