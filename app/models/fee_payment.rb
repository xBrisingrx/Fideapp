# == Schema Information
#
# Table name: fee_payments
#
#  id                   :bigint           not null, primary key
#  fee_id               :bigint
#  active               :boolean          default(TRUE)
#  date                 :date
#  detail               :string(255)      default("")
#  comment              :string(255)
#  tomado_en            :decimal(15, 2)   default(1.0)
#  total                :decimal(15, 2)   default(0.0)
#  payment              :decimal(15, 2)   default(0.0)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  payments_currency_id :bigint
#  code                 :string(255)      default("0")
#  valor_acarreado      :decimal(15, 2)   default(0.0)
#
class FeePayment < ApplicationRecord
  belongs_to :fee
  belongs_to :payments_currency
  has_one :currency, through: :payments_currency
  has_one :payments_type, through: :payments_currency
  has_many_attached :images

  validates :tomado_en,:date, :payment, :valor_acarreado, :code, presence: true 


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

  def payment_method
    "#{self.payments_type.name} en #{self.currency.name}"
  end

end
