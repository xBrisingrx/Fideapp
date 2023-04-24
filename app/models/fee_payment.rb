# == Schema Information
#
# Table name: fee_payments
#
#  id                        :bigint           not null, primary key
#  active                    :boolean          default(TRUE)
#  code                      :string(255)      default("0")
#  comment                   :string(255)
#  date                      :date
#  detail                    :string(255)      default("")
#  payment(Dinero ingresado) :decimal(15, 2)   default(0.0)
#  tomado_en                 :decimal(15, 2)   default(1.0)
#  total                     :decimal(15, 2)   default(0.0)
#  valor_acarreado           :decimal(15, 2)   default(0.0)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  fee_id                    :bigint
#  payments_currency_id      :bigint
#
# Indexes
#
#  index_fee_payments_on_fee_id                (fee_id)
#  index_fee_payments_on_payments_currency_id  (payments_currency_id)
#
# Foreign Keys
#
#  fk_rails_...  (fee_id => fees.id)
#  fk_rails_...  (payments_currency_id => payments_currencies.id)
#
class FeePayment < ApplicationRecord
  belongs_to :fee
  belongs_to :payments_currency
  has_one :currency, through: :payments_currency
  has_many_attached :images

  scope :actives, -> { where(active: true) }

  def disable 
    ActiveRecord::Base.transaction do
      payment = FeePayment.where( code: self.code )
      payment.each do |payment|
        payment.update(active: false)
        payment.fee.update_payment_data
      end
    end
  end

end
