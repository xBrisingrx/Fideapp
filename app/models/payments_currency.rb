# == Schema Information
#
# Table name: payments_currencies
#
#  id               :bigint           not null, primary key
#  active           :boolean          default(TRUE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  currency_id      :bigint
#  payments_type_id :bigint
#
# Indexes
#
#  index_payments_currencies_on_currency_id       (currency_id)
#  index_payments_currencies_on_payments_type_id  (payments_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (currency_id => currencies.id)
#  fk_rails_...  (payments_type_id => payments_types.id)
#
class PaymentsCurrency < ApplicationRecord
  belongs_to :payments_type
  belongs_to :currency

  scope :actives, -> { where(active:true) }

  def name
    "#{self.payments_type.name} - #{self.currency.name}"
  end
end
