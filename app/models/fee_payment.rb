# == Schema Information
#
# Table name: fee_payments
#
#  id                        :bigint           not null, primary key
#  active                    :boolean          default(TRUE)
#  comment                   :string(255)
#  date                      :date
#  detail                    :string(255)      default("")
#  payment(Dinero ingresado) :decimal(15, 2)   default(0.0)
#  tomado_en                 :decimal(15, 2)   default(1.0)
#  total                     :decimal(15, 2)   default(0.0)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  currency_id               :bigint
#  fee_id                    :bigint
#
# Indexes
#
#  index_fee_payments_on_currency_id  (currency_id)
#  index_fee_payments_on_fee_id       (fee_id)
#
# Foreign Keys
#
#  fk_rails_...  (currency_id => currencies.id)
#  fk_rails_...  (fee_id => fees.id)
#
class FeePayment < ApplicationRecord
  belongs_to :fee
  belongs_to :currency
  has_many_attached :images
end
