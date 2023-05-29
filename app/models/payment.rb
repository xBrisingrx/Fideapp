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

  before_validation :check_attributes
  after_create :apply_payment_to_fees

  scope :actives, -> { where(active: true) }
  scope :no_first_pay, -> { where(first_pay: false) }
  scope :is_first_pay, -> { where(first_pay: true) }

  private 

  def check_attributes
    self.date = self.sale.date if self.date.blank?
    self.total = self.payment * self.taken_in
  end

  def apply_payment_to_fees
    return if self.first_pay?
    byebug
    payment = Payment.where(sale_id: self.sale.id).no_first_pay.actives.sum(:total)
    fees = Fee.where(sale_id: self.sale.id).order('id ASC')
    fees.each do |fee|
      return if payment <= 0.0
      owes = fee.get_total_value
      fee.owes = fee.get_total_value
      if payment >= fee.owes
        fee.update(owes: 0, pay_status: :pagado, payed: true)
      else
        fee.update!(owes: fee.owes - payment, pay_status: :pago_parcial, payed: true )
      end
      payment -= owes
    end
  end


# def aplicar_pago payment, pay_date, code
#     # Obtengo todas las cuotas que no estan pagadas distintas a la que se esta pagando en este momento
#     fees_to_pay = Fee.where(sale_id: self.sale_id)
#                         .where('owes > 0')
#                         .order('id ASC')

#     fees_to_pay.each do |cuota|
      
#       puts "\n\n Payment menor a cero => #{payment.to_f} \n\n" if payment <= 0.0

#       return if payment <= 0.0
      
#       owes = cuota.owes #lo que se adeuda de esta cuota

#       if cuota.id == self.id # llegamos a la cuota en q se realiza el pago
#         fee_payment = FeePayment.find(code)
#         fee_payment.valor_acarreado = (payment < cuota.owes) ? payment : owes
#         fee_payment.save 
#         self.update( owes: self.owes - fee_payment.valor_acarreado )
#       else
#         # pago a registrar, se deja en cero el monto porque es para lleva el registro de adelantos/pago deuda
#         pago = cuota.fee_payments.new(
#           date: pay_date, 
#           payment: 0, 
#           tomado_en: 1,
#           total: 0,
#           payments_currency_id: 1,
#           code: code)

#         if payment < cuota.owes
#           cuota.update!(owes: cuota.owes - payment, pay_status: :pago_parcial, payed: true )
#           pago.valor_acarreado = payment
#           if cuota.due_date < pay_date 
#             pago.comment = "Pago parcial de deuda de esta cuota realizado cuando se pago la cuota ##{self.number} por un monto de $"
#           else 
#             pago.comment = "Se realizo un adelanto parcial de esta cuota cuando se pago la cuota ##{self.number} por un monto de $" 
#           end
#         else
#           cuota.update!(owes: 0.0, pay_status: :pagado, payed: true)
#           pago.valor_acarreado = owes
#           if cuota.due_date < pay_date 
#             pago.comment = "Pago total de deuda de esta cuota realizado cuando se pago la cuota ##{self.number} por un monto de $" 
#           else 
#             pago.comment = "Se realizo un pago adelantado de esta cuota cuando se pago la cuota ##{self.number} por un monto de $" 
#           end
#         end # if payment <= cuota.owes
#         # byebug
#         pago.save
#       end # if cuota.id == self.id
#       payment -= owes
#     end # fees_to_pay.each
#   end # pago_supera_cuota


end
