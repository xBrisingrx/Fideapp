# == Schema Information
#
# Table name: payments_types
#
#  id          :bigint           not null, primary key
#  active      :boolean          default(TRUE)
#  description :string(255)
#  name        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class PaymentsType < ApplicationRecord
	# tipos de pago que acepta el sistema [ efectivo, transferencia , etc ]
	has_many :payments_currencies
	has_many :currencies, through: :payments_currencies

	scope :actives, -> { where(active:true) }
end
