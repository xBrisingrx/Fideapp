# == Schema Information
#
# Table name: sales
#
#  id                 :bigint           not null, primary key
#  status             :boolean          default(NULL)
#  apply_arrear       :boolean          default(TRUE), not null
#  arrear             :decimal(15, 2)   default(0.5), not null
#  comment            :text(65535)
#  date               :date             not null
#  due_day            :integer          default(10), not null
#  number_of_payments :integer          not null
#  price              :decimal(15, 2)   default(0.0), not null
#  land_id            :bigint
#  active             :boolean          default(TRUE)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  refinanced         :boolean          default(FALSE)
#
class Sale < ApplicationRecord
	has_many :sale_clients, dependent: :destroy
	has_many :clients, through: :sale_clients
	has_many :sale_products, dependent: :destroy
	belongs_to :land 
	has_many :fees, dependent: :destroy 
	has_many :fee_payments, through: :fees
	has_many :payments, dependent: :destroy

	before_create :set_attributes 
	after_create :register_activity
	accepts_nested_attributes_for :sale_clients, :sale_products, :fees

	enum status: [:not_approved, :approved, :payed]

	def calculate_total_value!
		# Se calcula el valor final de la venta, al momento de vender el lote
		valor_venta = self.fees.sum(:total_value) + self.payments.is_first_pay.sum(:total)
		self.update( price: valor_venta )
	end

	def generar_cuotas number_cuota_increase, valor_cuota_aumentada, valor_cuota, fee_start_date
  	aumenta_cuota = ( number_cuota_increase > 0 ) && ( valor_cuota_aumentada > 0 )

  	if fee_start_date.empty?
  		due_date = Time.new(self.date.year, self.date.month, self.due_day)
  	else
  		start_date = Date.parse fee_start_date
  		due_date = Time.new(start_date.year, start_date.month, start_date.day)
  		due_date -= 1.month
  	end


    for i in 1..self.number_of_payments
      # genero mis cuotas
      due_date += 1.month
      # El valor de la cuota puede ser que cambie , el valor total incrementa
      if aumenta_cuota && i >= number_cuota_increase
        value = valor_cuota_aumentada
      else
        value = valor_cuota
      end

      self.fees.create!(
      	due_date: due_date, 
        value: value, 
        number: i, 
        owes: value, 
        total_value: value
      )
    end
	end # generar cuota

	def generar_cuotas_manual valores_cuotas, fee_start_date
		if fee_start_date.empty?
  		due_date = Time.new(self.date.year, self.date.month, self.due_day)
  	else
  		start_date = Date.parse fee_start_date
  		due_date = Time.new(start_date.year, start_date.month, start_date.day)
  		due_date -= 1.month
  	end

		i = 0
		myArray = valores_cuotas[0].split(',')
		myArray.each do |valor|
			i += 1
			due_date += 1.month
			self.fees.create!(
      	due_date: due_date, 
        value: valor.to_f, 
        number: i, 
        owes: valor.to_f, 
        total_value: valor.to_f
      )
		end
	end

	def total_pagado
		# self.fees.where(payed: true).sum(:payment)
		# self.payments.actives.sum(:payment)
		puts '###### MODEL SALE -> TOTAL PAGADO'
		byebug
	end

	def get_all_owes # el valor que falta pagar para cancelar la venta
		self.total_value - self.saldo_pagado
	end

	def get_primer_pago
		first_pay = self.fees.where(number: 0).first
		if first_pay.nil?
			0
		else 
			first_pay.payment
		end
	end

	def product_name
		product = self.sale_products.first
		case product.product_type
		when 'Land'
			name = 'Tierra'
		when 'Sale'
			name = refinanced_name( product.product_id )
		else
			name = Project.find(product.product_id).project_type.name
		end
		# if product.product_type == 'Land'
		# 	name = 'Tierra'
		# else
		# 	name = Project.find(product.product_id).project_type.name
		# end
		name
	end

	def refinanced_name( sale_id )
		sale = Sale.find(sale_id)
		product = sale.sale_products.first 
		if product.product_type == 'Land'
			name = 'Tierra'
		else
			name = Project.find(product.product_id).project_type.name
		end
		"Refinanciacion de #{name}"
	end

	def saldo_pagado
		self.payments.actives.sum(:total)
	end

	def total_value # aca tenemos el valor total de la venta (cuotas + ajustes + moras)
		total = self.payments.is_first_pay.sum(:total) #1er pago
		
		if self.refinanced?
			total += self.payments.no_first_pay.sum(:total)
		else
			self.fees.each do |fee|
				total += fee.total_value
			end
		end
		total
	end

	def set_refinancied
		ActiveRecord::Base.transaction do
			self.update(refinanced: true)
			self.fees.each do |fee|
				fee.set_refinancied()
			end
		end
	end

	def owes_this_month
		# obtenemos lo que se deberia pagar este mes sin sumar atrasos
		# que no haya nada para pagar puede ser porque ya paso la fecha de todas las cuotas 
		# o xq se pacto que las cuotas corren a partir un mes mas adelante ( cuando pactan q se empieza a pagar dentro de X meses )
		month = Time.new.month
		pay_this_month = 0
		fee = self.fees.where( 'month(due_date) = ?', month ).first
		if fee.blank? # si este mes no habia nada para pagar 
			fee = self.fees.last # obtenemos la ultima cuota 
			if fee.due_date.month < month 
				pay_this_month = fee.total_value
			end
		else
			pay_this_month = fee.total_value
		end
		pay_this_month
	end

	def has_no_payed_fees?
		!self.fees.where(payed: false).empty?
	end

	def primer_cuota_impaga 
		# es importante tenes la primer cuota impaga para calcular los intereses y la deuda
		self.fees.where(payed: false).order(:number).first
	end

	def fecha_inicio_interes
		date = self.primer_cuota_impaga.due_date
		"#{date.year}-#{date.month}-01"
	end
	
	private

	def register_activity
		ActivityHistory.new( action: :create_record, description: "Venta realizada", 
      record: self, date: Time.now, user: Current.user )
	end

	def set_attributes
		self.date = Time.now.strftime("%Y/%m/%d") if self.date.blank? 
		self.due_day = 10 if self.due_day.blank? 
		self.arrear = 0 if self.arrear.blank? 
	end
end
