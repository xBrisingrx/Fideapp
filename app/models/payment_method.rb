# == Schema Information
#
# Table name: payment_methods
#
#  id          :bigint           not null, primary key
#  active      :boolean          default(TRUE)
#  description :string(255)
#  name        :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class PaymentMethod < ApplicationRecord
	validates :name, presence: true, 
		uniqueness: { case_sensitive: false, message: "Este metodo de pago ya se encuentra registrdo" }
end
