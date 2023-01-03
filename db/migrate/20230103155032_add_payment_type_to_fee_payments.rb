class AddPaymentTypeToFeePayments < ActiveRecord::Migration[5.2]
  def change
    add_reference :fee_payments, :payment_type, foreign_key: true
  end
end
