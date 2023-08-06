# == Schema Information
#
# Table name: payments_currencies
#
#  id               :bigint           not null, primary key
#  payments_type_id :bigint
#  currency_id      :bigint
#  active           :boolean          default(TRUE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class PaymentsCurrency < ApplicationRecord
  belongs_to :payments_type
  belongs_to :currency

  scope :actives, -> { where(active:true) }

  def name
    "#{self.payments_type.name} - #{self.currency.name}"
  end
end
