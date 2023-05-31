class AddPaymentToCreditNote < ActiveRecord::Migration[5.2]
  def change
    add_reference :credit_notes, :payment, foreign_key: true
  end
end
