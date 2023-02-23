class ChangeForeingKeyTableFeePayments < ActiveRecord::Migration[5.2]
  def up
    remove_reference :fee_payments, :payments_type, foreign_key: true
    remove_reference :fee_payments, :currency, foreign_key: true
    add_reference :fee_payments, :payments_currency, foreign_key: true
  end

  def down
    add_reference :fee_payments, :payments_type, foreign_key: true
    add_reference :fee_payments, :currency, foreign_key: true
    remove_reference :fee_payments, :payments_currency, foreign_key: true
  end
end
