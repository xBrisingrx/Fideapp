# == Schema Information
#
# Table name: fees
#
#  id          :bigint           not null, primary key
#  due_date    :date
#  interest    :decimal(15, 2)   default(0.0), not null
#  number      :integer          not null
#  owes        :decimal(15, 2)   default(0.0), not null
#  pay_date    :date
#  payed       :boolean          default(FALSE)
#  payment     :decimal(15, 2)   default(0.0), not null
#  total_value :decimal(15, 2)   default(0.0), not null
#  value       :decimal(15, 2)   default(0.0), not null
#  comment     :string(255)      default("")
#  pay_status  :integer          default("pendiente")
#  sale_id     :bigint
#  active      :boolean          default(TRUE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Fee < ApplicationRecord
  # La cuota es un acuerdo de pagos
  # Se pacta con el cliente 
  belongs_to :sale
  has_many :adjusts, dependent: :destroy
  has_many :interests, dependent: :destroy
  has_many :fee_payments, dependent: :destroy

  scope :actives, -> { where(active: true) }
  scope :no_cero, -> { where( "number > 0" ) }
  scope :no_payed, -> { where.not(pay_status: :pagado) }
  scope :no_refinancied, -> { where.not(pay_status: :refinancied) }

  enum pay_status: [:pendiente, :pagado, :pago_parcial, :refinancied]

  def calcular_primer_pago
    primer_pago = self.fee_payments.sum(:total)
    self.update( payment: primer_pago , value: primer_pago ,total_value: primer_pago )
  end

  def interes_diario 
    ( (self.sale.arrear/100) * self.value )
  end

  def calcular_interes date = nil
    interes_diario = ( (self.sale.arrear/100) * self.value)
    primer_cuota_vencida = self.sale.fees.actives.no_payed.order('id ASC').first
    compare_date = (date.nil?) ? Date.today : date
    dias_vencido = compare_date - Date.new( primer_cuota_vencida.due_date.year, primer_cuota_vencida.due_date.month, 01 )
    total = (interes_diario * dias_vencido).round(2)
    total
  end

  def expired?
    self.due_date.strftime("%F")  < Time.new.strftime("%F") 
  end

  def apply_arrear?
    there_is_payment_this_month = Payment.where( 'extract(month from date) = ?', self.due_date.month ).where(sale_id: self.sale_id).actives.no_first_pay
    self.expired? && self.sale.apply_arrear && there_is_payment_this_month.empty?
  end

  def is_last_fee? #verificamos si esta es la ultima cuota de esta venta
    last_fee = Fee.where( sale_id: self.sale_id ).actives.order(:number).last 
    self.id == last_fee.id 
  end

  def get_deuda
    #obtenemos los pagos de los meses hasta esta cuota
    # y los restamos por el valor de las cuotas para saber cuanto se debe
    # hasta ese mes 
    Fee.where(sale_id: self.sale_id)
      .where('number <= ?', self.number)
      .sum('owes')  
  end

  def get_deuda_cuotas_anteriores
    Fee.where(sale_id: self.sale_id)
      .where('number < ?', self.number)
      .sum('owes')
  end

  def has_debt?
    self.get_deuda > 0
  end

  def get_fee_owes
    self.total_value - self.fee_payments.sum(:valor_acarreado)
  end

  def get_total_value
    adjust = self.adjusts.sum(:value)
    interest = self.interests.sum(:value)
    self.value + adjust + interest
  end

  def update_total_value #actualizamos el valor total de la cuota
    adjust = self.adjusts.sum(:value)
    interest = self.interests.sum(:value)
    total_value = self.value + adjust + interest
    self.update(total_value: total_value)
  end

 ##### AJUSTE ####
  def increase_adjust adjust, comment
    self.adjusts.create( value: adjust, comment: comment )

    self.total_value = self.value + self.get_adjusts + self.interest
    self.owes = self.total_value - self.fee_payments.sum(:valor_acarreado)

    self.save
  end

  def apply_adjust_one_fee adjust, comment
    self.increase_adjust(adjust, comment)
  end

  def apply_adjust_include_fee adjust, comment
    cuotas = Fee.where(["sale_id = ? and number >= ?", self.sale_id, self.number ])
    cuotas.each do |cuota|
      cuota.increase_adjust(adjust, comment)
    end
  end
############# AJUSTE
  
  def apply_adjust adjust, comment
    puts "\n\n\n\n\n ****************5 Aplicamos el ajuste a partir de la cuota #{self.number} \n"
    cuotas = Fee.where(["sale_id = ? and number >= ?", self.sale_id, self.number ])
    cuotas.each do |cuota|
      "\n Ajustamos en la cuota #{cuota.number} \n"
      cuota.adjusts.create(value:  adjust, comment: comment)
      "\n Update exitoso"
    end
  end

  def get_adjusts
    self.adjusts.sum(:value)
  end

  def get_interests
    self.interests.sum(:value)
  end

  def aplicar_pago payment, pay_date, code
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

  def reset_payments
    self.fee_payments.destroy_all
    self.update(
      owes: self.value,
      total_value: self.value,
      comment: '',
      comment_adjust:'',
      adjust: 0,
      pay_status: :pendiente,
      payment: 0,
      payed: 0,
      interest: 0
    )
  end

  def show_owes_in_table
    first_month_day = Date.today.beginning_of_month
    last_month_day = Date.today.end_of_month
    label = '0'
    if ( self.due_date < last_month_day )
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

  def get_payments
    # self.fee_payments.actives.sum(:total)
    desired_month = self.due_date.month
    # pagos efectuados el mes indicado
    Payment.where('extract(month from date) = ?', desired_month)
      .where(sale_id: self.sale_id)
      .no_first_pay.actives
      .sum(:total)
  end

  def get_payments_list
    sale = Sale.find(self.sale_id)
    desired_month = self.due_date.month

    if sale.fees.last.id == self.id 
      # lista de pagos efectuados en la ultima cuota o mas tarde
      Payment.where('extract(month from date) >= ?', desired_month).where(sale_id: self.sale_id).no_first_pay.actives.order(date: :asc)
    else
      # lista de pagos efectuados el mes indicado
      Payment.where('extract(month from date) = ?', desired_month).where(sale_id: self.sale_id).no_first_pay.actives.order(date: :asc)
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
    month = date.month 
    fee = Fee.where('extract(month  from due_date) = ?', month).where(sale_id: sale_id)
    if fee.empty?
      current_fee = Sale.find(sale_id).fees.last 
    else 
      current_fee = fee.first
    end
  end

  def reset
    fees = Fee.where(sale_id: self.sale_id)
    fees.each do |fee|
      fee.update(pay_status: :pendiente, owes: fee.get_total_value, payed: false)
    end
  end

  def set_refinancied
    if self.pay_status != :pagado
      self.update(owes: 0, pay_status: :refinancied)
    end
  end

end
