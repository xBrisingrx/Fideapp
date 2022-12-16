# == Schema Information
#
# Table name: sales
#
#  id                                        :bigint           not null, primary key
#  active                                    :boolean          default(TRUE)
#  apply_arrear(Venta aplica mora)           :boolean          default(FALSE), not null
#  arrear(% de mora)                         :integer          default(0), not null
#  comment                                   :text(65535)
#  date(Fecha en que se realizo la venta)    :date             not null
#  due_day(Num dia de vencimiento de pagos)  :integer          default(10), not null
#  number_of_payments(Num de cuotas inicial) :integer          not null
#  price(Valor inicial de venta)             :decimal(15, 2)   default(0.0), not null
#  status                                    :boolean          default(NULL)
#  created_at                                :datetime         not null
#  updated_at                                :datetime         not null
#  land_id                                   :bigint
#
# Indexes
#
#  index_sales_on_land_id  (land_id)
#
# Foreign Keys
#
#  fk_rails_...  (land_id => lands.id)
#
class Sale < ApplicationRecord
	has_many :sale_clients, dependent: :destroy
	has_many :clients, through: :sale_clients
	has_many :sale_products, dependent: :destroy
	belongs_to :land 
	has_many :fees, dependent: :destroy 
	has_many :fee_payments, through: :fees

	before_create :set_attributes 
	
	enum status: [:not_approved, :approved, :payed]

	def set_attributes
		self.date = Time.now.strftime("%Y/%m/%d") if self.date.blank? 
		self.due_day = 10 if self.due_day.blank? 
		self.arrear = 0 if self.arrear.blank? 
	end

	def calculate_total_value!
		# Se calcula el valor final de la venta, al momento de vender el lote
		valor_venta = self.fees.sum(:total_value)
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
		self.fees.where(payed: true).sum(:payment)
	end

	def get_all_owes
		self.fees.sum(:owes)
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
		if product.product_type == 'Land'
			name = 'Tierra'
		else
			name = Project.find(product.product_id).project_type.name
		end
		name
	end
	
end
