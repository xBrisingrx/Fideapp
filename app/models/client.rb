# == Schema Information
#
# Table name: clients
#
#  id             :bigint           not null, primary key
#  active         :boolean          default(TRUE), not null
#  code           :string(255)      not null
#  direction      :string(255)
#  dni            :string(20)
#  email          :string(100)
#  last_name      :string(255)      not null
#  marital_status :string(30)
#  name           :string(255)      not null
#  phone          :string(60)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class Client < ApplicationRecord
	has_many :sale_clients
	
	validates :code, presence: true
	validates :name, presence: true
	validates :last_name, presence: true
	validates :dni, uniqueness: { message: "Este dni pertenece a otro cliente" }, allow_blank: true

	scope :actives, -> { where(active: true) }

	def fullname
		"#{self.last_name} #{self.name}"	
	end
end
