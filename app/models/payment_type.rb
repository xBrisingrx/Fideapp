class PaymentType < ApplicationRecord
	# tipos de pago que acepta el sistema [ efectivo, transferencia , etc ]
	has_many :payments_currencies
	has_many :currencies, through: :payments_currencies
end
