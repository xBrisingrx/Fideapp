class AddCodeToFeePayments < ActiveRecord::Migration[5.2]
  def change
    add_column :fee_payments, :code, :string, default: '0'
    add_column :fee_payments, :valor_acarreado, :decimal, precision: 15, scale: 2, default: 0
  end
end
