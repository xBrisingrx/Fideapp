# == Schema Information
#
# Table name: fees
#
#  id         :bigint           not null, primary key
#  due_date   :date
#  interest   :decimal(15, 2)   default(0.0), not null
#  number     :integer          not null
#  pay_date   :date
#  payed      :boolean          default(FALSE)
#  payment    :decimal(15, 2)   default(0.0), not null
#  value      :decimal(15, 2)   default(0.0), not null
#  comment    :string(255)      default("")
#  pay_status :integer          default("pendiente")
#  sale_id    :bigint
#  active     :boolean          default(TRUE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  type_fee   :integer          default("quote")
#
class Fee < ApplicationRecord
  # La cuota es un acuerdo de pagos
  # Se pacta con el cliente 
  # total_value es el valor de la cuota + ajustes + interes

  belongs_to :sale
  has_many :adjusts, dependent: :destroy
  has_many :interests, dependent: :destroy

  attr_accessor :number_of_fees_to_add

  validates :due_date, :number, :value, presence: true
  validates :value, numericality: { greater_than: 0 }
  validate :greater_than_previous_fee, on: :create

  scope :actives, -> { where(active: true) }
  scope :no_cero, -> { where( "number > 0" ) }
  scope :no_payed, -> { where.not(pay_status: :pagado) }
  scope :no_refinancied, -> { where.not(pay_status: :refinancied) }

  enum pay_status: [:pendiente, :pagado, :pago_parcial, :refinancied]
  enum type_fee: [ :no_valid ,:first_pay, :quote]
  
  after_create :verify_number_of_fees_to_add
  def calcular_primer_pago
    primer_pago = self.fee_payments.sum(:total)
    self.update( payment: primer_pago , value: primer_pago )
  end

  def interes_diario 
    # ( (self.sale.arrear/100) * self.value )
    0
  end

  def calcular_interes date = nil
    # la ultima cuota vencida es toda cuota que no este en estado PAGADO
    # interes_diario = ( (self.sale.arrear/100) * self.value)
    interes_diario = 0
    primer_cuota_vencida = self.sale.fees.actives.no_payed.order(:number).first
    if primer_cuota_vencida.blank?
      0
    else
      compare_date = (date.nil?) ? Date.today : date
      dias_vencido = compare_date - Date.new( primer_cuota_vencida.due_date.year, primer_cuota_vencida.due_date.month, 01 )
      total = (interes_diario * dias_vencido).round(2)
      total
    end
  end

  def expired?
    self.due_date.strftime("%F")  < Time.new.strftime("%F") 
  end

  def apply_arrear?
    # en realidad, si la cuota no esta pagada , no importa que hayan pagos ese mes, seguiria vencida
    there_is_payment_this_month = Payment.where( 'extract(month from date) = ?', self.due_date.month ).where(sale_id: self.sale_id).actives.no_first_pay
    self.expired? && there_is_payment_this_month.empty?

  end

  def is_last_fee? #verificamos si esta es la ultima cuota de esta venta
    last_fee = Fee.where( sale_id: self.sale_id ).actives.order(:number).last 
    self.id == last_fee.id 
  end

  def is_first_fee? #verificamos si esta es la ultima cuota de esta venta
    last_fee = Fee.where( sale_id: self.sale_id ).actives.order(:number).first 
    self.id == last_fee.id 
  end

  def get_deuda
    #obtenemos los pagos de los meses hasta esta cuota
    # y los restamos por el valor de las cuotas para saber cuanto se debe
    # hasta ese mes 
    end_month = Date.today.end_of_month()
    fees = Fee.where(sale_id: self.sale_id).where('due_date <= ?', end_month)
    #obtenemos los pagos realizados en las cuotas, omitimos la primer entrega
    paymets = Payment.where( sale_id: self.sale_id ).actives.no_first_pay.sum(:total)
    owes = 0
    fees.each do |fee|
      owes += fee.total_value
    end
    owes -= paymets
    if owes < 0 && !self.is_last_fee?
      # el pago supera a lo adeudado hasta esta cuota, significa que fue cancelada
      0
    else
      owes
    end
  end

  def owes
    self.get_deuda
  end

  def has_debt?
    self.get_deuda > 0
  end

  def total_value
    adjust = self.adjusts.sum(:value)
    interest = self.interests.sum(:value)
    self.value + adjust + interest
  end

  def update_total_value #actualizamos el valor total de la cuota
    adjust = self.adjusts.sum(:value)
    interest = self.interests.sum(:value)
    total_value = self.value + adjust + interest
    # self.update(total_value: total_value)
    # UPDATE TOTAL VALUE
    total_value
  end

  def get_adjusts
    self.adjusts.sum(:value)
  end

  def get_interests
    self.interests.sum(:value)
  end

  def aplicar_pago payment, pay_date, code
    ## APLICAR PAGO
    # Obtengo todas las cuotas que no estan pagadas distintas a la que se esta pagando en este momento
    fees_to_pay = Fee.where(sale_id: self.sale_id)
                        .where('owes > 0')
                        .order('id ASC')

    fees_to_pay.each do |cuota|
      
      puts "\n\n Payment menor a cero => #{payment.to_f} \n\n" if payment <= 0.0

      return if payment <= 0.0
      
      owes = cuota.owes #lo que se adeuda de esta cuota

      if cuota.id == self.id # llegamos a la cuota en q se realiza el pago
        fee_payment = FeePayment.find(code)
        fee_payment.valor_acarreado = (payment < cuota.owes) ? payment : owes
        fee_payment.save 
        self.update( owes: self.owes - fee_payment.valor_acarreado )
      else
        # pago a registrar, se deja en cero el monto porque es para lleva el registro de adelantos/pago deuda
        pago = cuota.fee_payments.new(
          date: pay_date, 
          payment: 0, 
          tomado_en: 1,
          total: 0,
          payments_currency_id: 1,
          code: code)

        if payment < cuota.owes
          cuota.update!(owes: cuota.owes - payment, pay_status: :pago_parcial, payed: true )
          pago.valor_acarreado = payment
          if cuota.due_date < pay_date 
            pago.comment = "Pago parcial de deuda de esta cuota realizado cuando se pago la cuota ##{self.number} por un monto de $"
          else 
            pago.comment = "Se realizo un adelanto parcial de esta cuota cuando se pago la cuota ##{self.number} por un monto de $" 
          end
        else
          cuota.update!(owes: 0.0, pay_status: :pagado, payed: true)
          pago.valor_acarreado = owes
          if cuota.due_date < pay_date 
            pago.comment = "Pago total de deuda de esta cuota realizado cuando se pago la cuota ##{self.number} por un monto de $" 
          else 
            pago.comment = "Se realizo un pago adelantado de esta cuota cuando se pago la cuota ##{self.number} por un monto de $" 
          end
        end # if payment <= cuota.owes

        pago.save
      end # if cuota.id == self.id
      payment -= owes
    end # fees_to_pay.each
  end # pago_supera_cuota

  def show_owes_in_table
    first_month_day = Date.today.beginning_of_month
    last_month_day = Date.today.end_of_month
    label = '0'
    if ( self.due_date < last_month_day )
      # show_owes_in_table
      label = self.get_deuda + self.owes
    end
    label
  end

  def due_current_month
    first_month_day = Date.today.beginning_of_month
    last_month_day = Date.today.end_of_month

    if ( self.due_date <= last_month_day ) && ( self.due_date >= first_month_day )
      return true
    end

    if ( self.due_date < last_month_day ) && ( self.id == self.sale.fees.last.id )
      return true
    end
    return false
  end

  def adeuda_pago
    self.pago_parcial? || (self.payed? && self.owes > 0)
  end

  def get_payments #obtenemos los pagos realizados el mes de esta cuota
    from_date = "#{self.due_date.year}-#{self.due_date.month}-01"
    to_date = "#{self.due_date.year}-#{self.due_date.month}-31"
    payments = Payment.where(sale_id: self.sale_id).no_first_pay.actives
    # si es la primer cuota, le corresponden todo los pagos previos al 31 de su mes
    payments = payments.where('date >= ?', from_date) if !self.is_first_fee? 
    # si es la ultima cuota, le corresponden todo los pagos posteriores al 1ero de su mes
    payments = payments.where( 'date <= ?', to_date ) if !self.is_last_fee?   
    payments.sum(:total)
  end
  
  def get_payments_list
    sale = Sale.find(self.sale_id)
    desired_month = self.due_date.month
    desired_year = self.due_date.year
    if sale.fees.last.id == self.id 
      # lista de pagos efectuados en la ultima cuota o mas tarde
      Payment.where('extract(month from date) >= ?', desired_month)
        .where('extract(year from date) >= ?', desired_year)
        .where(sale_id: self.sale_id)
        .no_first_pay.actives.order(date: :asc)
    elsif sale.fees.first.id == self.id
      Payment.where('extract(month from date) <= ?', desired_month)
        .where('extract(year from date) <= ?', desired_year)
        .no_first_pay.actives.order(date: :asc)
        .where(sale_id: self.sale_id)
    else
      # lista de pagos efectuados el mes indicado
      Payment.where('extract(month from date) = ?', desired_month)
        .where(sale_id: self.sale_id)
        .where('extract(year from date) >= ?', desired_year)
        .no_first_pay.actives.order(date: :asc)
    end
  end

  def update_payment_data
    payments = self.fee_payments.actives
    self.interest = 0
    self.total_value = self.value + self.get_adjusts
    self.payment = payments.sum(:valor_acarreado)
    self.owes = self.total_value - self.payment
    self.pay_status = ( self.owes == self.total_value ) ? 0 : 2
    self.payed = !self.pendiente?
    self.save
  end

  def self.current_fee( sale_id, date = Time.new )
    # le tengo que buscar un mejor nombre al metodo
    month = date.month
    year = date.year 
    fee = Fee.where('extract(month  from due_date) = ?', month)
      .where('extract(year  from due_date) = ?', year)
      .where.not(pay_status: :pagado)
      .where(sale_id: sale_id)
    if fee.empty?
      # escenario donde se paso la fecha de vencimiento de la ultima cuota o 
      fees = Sale.find(sale_id).fees.where.not(pay_status: :pagado)
      if fees.first.due_date > date
      # escenario donde estamos adelantando pagos
      # ejemplo, estan ingresando pagos y la cuota a pagar es la del mes siguiente
        current_fee = fees.first
      else
        fees.last
      end
    else 
      current_fee = fee.first
    end
  end

  def reset
    Fee.where(sale_id: self.sale_id).update_all(pay_status: :pendiente, payed: false)
  end

  def set_refinancied
    if self.pay_status != :pagado
      self.update(pay_status: :refinancied)
    end
  end

  def verify_number_of_fees_to_add
    # metodo que uso cuando agrego cuotas de forma manual, desde la vista de pagar cuotas
    return if self.number_of_fees_to_add.nil?
    fees_to_add = self.number_of_fees_to_add.to_i - 1
    if fees_to_add > 0
      due_date = self.due_date += 1.month
      number = self.number += 1
      fees_to_add.times do
        Fee.create(
          due_date: due_date,
          value: self.value,
          number: number,
          sale: self.sale
        )
        due_date += 1.month
        number += 1
      end
    end
    self.sale.calculate_total_value!
    self.sale.update(status: :approved) # si la venta habia sido pagada por completo hay que cambiar el estado
  end

  def greater_than_previous_fee
    # last_fee = self.sale.fees.order(number: 'ASC').no_cero.last
    # if !last_fee.blank?
    #   if self.due_date <= last_fee.due_date
    #     error(:due_date, "Esta cuota debe tener un vencimiento posterior a la cuota anterior")
    #   end
    # end
  end

end
