# == Schema Information
#
# Table name: payments
#
#  id                   :bigint           not null, primary key
#  sale_id              :bigint
#  date                 :date             not null
#  payments_currency_id :bigint
#  payment              :decimal(15, 2)   not null
#  taken_in             :decimal(15, 2)   default(1.0)
#  total                :decimal(15, 2)
#  first_pay            :boolean          default(FALSE)
#  comment              :text(65535)
#  active               :boolean          default(TRUE)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
class Payment < ApplicationRecord
  # si el pago no esta activo es q pertenece a una nota de credito
  # los pagos pertenecen a una venta
  # no se le asigna un id de cuota, el pago pertenece a la cuota dependiendo en que fecha fue ingresado
  belongs_to :sale
  belongs_to :payments_currency
  has_one :currency, through: :payments_currency
  has_one :payments_type, through: :payments_currency
  has_one :adjust, dependent: :destroy
  has_one :interest, dependent: :destroy
  has_many_attached :files
  has_one :credit_note, dependent: :destroy
  attr_accessor :interest
  attr_accessor :porcent_interest
  attr_accessor :adjust
  attr_accessor :comment_adjust

  validates :taken_in,:date, :payment, :total ,presence: true
  validates :taken_in, :payment, :total, numericality: true
  validate :interest_presence

  before_validation :check_attributes

  after_create :add_interest_to_fee, :add_adjust_to_fee
  after_create :apply_payment_to_fees

  scope :actives, -> { where(active: true) }
  scope :no_first_pay, -> { where(first_pay: false) }
  scope :is_first_pay, -> { where(first_pay: true) }

  def self.by_month sale_id, date # pagos ingresados en la fecha correspondiente a esta cuoda
    from_date = "#{date.year}-#{date.month}-01"
    to_date = "#{date.year}-#{date.month}-31"
    Payment.where('date >= ?', from_date).where('date <= ?', to_date).where(sale_id: sale_id).actives.no_first_pay
  end

  def self.payments_last_fee sale_id, date # pagos ingresados en la fecha de la ultima cuota o mas adelante
    from_date = "#{date.year}-#{date.month}-01"
    Payment.where('date >= ?', from_date).where(sale_id: sale_id).actives.no_first_pay
  end

  # def self.until_fee sale_id, date
  #   date = "#{date.year}-#{date.month}-31"
  #   Payment.where(sale_id:sale_id).no_first_pay.actives.where( 'date <= ?', date ).sum(:total)
  # end

  def disable 
    ActiveRecord::Base.transaction do
      self.update(active: false)
      apply_payment_to_fees
      self.adjust.destroy if !self.adjust.blank?
      self.interest.destroy if !self.interest.blank?
    end
  end

  def apply_payment_to_fees
    # hice una copia de este metodo en sale_model#update_payment_status
    return if self.first_pay?
    payment = Payment.where(sale_id: self.sale.id).no_first_pay.actives.sum(:total)
    fees = Fee.where(sale_id: self.sale.id).order('id ASC')
    fees.first.reset
    fees.each do |fee|
      return if payment <= 0.0
      owes = fee.total_value
      if payment >= owes
        # el pago supera el valor de la cuota, eso quiere decir q se cancela entera
        fee.update(pay_status: :pagado, payed: true, payment: owes)
      else
        # no se pago entera, solo se pago lo que quedo en payment
        fee.update!(pay_status: :pago_parcial, payed: true, payment: payment )
      end
      payment -= owes
    end
  end

  private 

  def check_attributes
    self.date = self.sale.date if self.date.blank?
    self.total = self.payment * self.taken_in
  end

  def add_adjust_to_fee #si al pago se le aplico un ajuste se lo agrego a la cuota vigente
    if self.adjust.to_f > 0
      fee = Fee.current_fee( self.sale_id, self.date.to_time )
      fee.adjusts.create( value: self.adjust.to_f, 
        date: self.date,
        payment: self,
        comment: self.comment_adjust )
    end
  end

  def add_interest_to_fee#si al pago se le aplico mora se la agrego a la cuota vigente
    if self.interest.to_f > 0
      fee = Fee.current_fee( self.sale_id, self.date.to_time )
      interest = fee.interests.create( value: self.interest.to_f,
        date: self.date,
        payment: self,
        comment: 'Mora por pago fuera de termino.' )
    end
  end

  def interest_presence
    if self.porcent_interest.to_f > 0 && self.interest.to_f <= 0
      errors.add(:interest, "Debe ingresar un valor de mora.")
    end
  end
end
