# == Schema Information
#
# Table name: currencies
#
#  id            :bigint           not null, primary key
#  active        :boolean          default(TRUE)
#  detail        :string(255)
#  name          :string(40)       not null
#  need_exchange :boolean          default(FALSE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Currency < ApplicationRecord
	has_many :payments_currencies
	
	validates :name, presence: true, uniqueness: { message: 'Ya se encuentra registrada esta divisa'}
	
	scope :actives, -> { where(active: true) }
end
