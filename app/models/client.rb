class Client < ApplicationRecord
	validates :code, presence: true
	validates :name, presence: true
	validates :last_name, presence: true
	validates :dni, uniqueness: { message: "Este dni pertenece a otro cliente" }, allow_blank: true

	
	def fullname
		"#{self.last_name} #{self.name}"	
	end
end
