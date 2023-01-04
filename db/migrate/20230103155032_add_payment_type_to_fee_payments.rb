class AddPaymentTypeToFeePayments < ActiveRecord::Migration[5.2]
  def change
    add_reference :fee_payments, :payments_type, foreign_key: true
  end
end
