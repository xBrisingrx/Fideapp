# == Schema Information
#
# Table name: payments
#
#  id                                           :bigint           not null, primary key
#  active                                       :boolean          default(TRUE)
#  comment                                      :text(65535)
#  date                                         :date             not null
#  first_pay(Si pertenece a la primer entrega)  :boolean          default(FALSE)
#  payment                                      :decimal(10, )    not null
#  taken_in(A que valor en $ se tomo la moneda) :decimal(15, 2)   default(1.0)
#  total(Calculo del valor pagado en $)         :decimal(15, 2)
#  created_at                                   :datetime         not null
#  updated_at                                   :datetime         not null
#  payments_currency_id                         :bigint
#  sale_id                                      :bigint
#
# Indexes
#
#  index_payments_on_payments_currency_id  (payments_currency_id)
#  index_payments_on_sale_id               (sale_id)
#
# Foreign Keys
#
#  fk_rails_...  (payments_currency_id => payments_currencies.id)
#  fk_rails_...  (sale_id => sales.id)
#
class Payment < ApplicationRecord
  # si el pago no esta activo es q pertenece a una nota de credito

  belongs_to :sale
  belongs_to :payments_currency
  has_one :currency, through: :payments_currency
  has_one :payments_type, through: :payments_currency
  has_many_attached :images

  validates :taken_in,:date, :payment, :total, presence: true
  validates :taken_in, :payment, :total, numericality: true

  before_validation :check_attributes
  after_create :apply_payment_to_fees

  scope :actives, -> { where(active: true) }
  scope :no_first_pay, -> { where(first_pay: false) }
  scope :is_first_pay, -> { where(first_pay: true) }

  def self.by_month sale_id, month
    Payment.where( 'extract(month from date) = ?', month ).where(sale_id: sale_id).actives.no_first_pay
  end

  def disable 
    ActiveRecord::Base.transaction do
      self.update(active: false)
      apply_payment_to_fees
    end
  end

  private 

  def check_attributes
    self.date = self.sale.date if self.date.blank?
    self.total = self.payment * self.taken_in
  end

  def apply_payment_to_fees
    return if self.first_pay?
    payment = Payment.where(sale_id: self.sale.id).no_first_pay.actives.sum(:total)
    fees = Fee.where(sale_id: self.sale.id).order('id ASC')
    fees.first.reset
    fees.each do |fee|
      return if payment <= 0.0
      owes = fee.get_total_value
      fee.owes = fee.get_total_value
      if payment >= fee.owes
        # el pago supera el valor de la cuota, eso quiere decir q se cancela entera
        # owes es el valor total q habia q pagar en esta cuota
        fee.update(owes: 0, pay_status: :pagado, payed: true, payment: owes)
      else
        # no se pago entera, solo se pago lo que quedo en payment
        fee.update!(owes: fee.owes - payment, pay_status: :pago_parcial, payed: true, payment: payment )
      end
      payment -= owes
    end
  end

end
