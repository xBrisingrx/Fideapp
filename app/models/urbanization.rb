# == Schema Information
#
# Table name: urbanizations
#
#  id         :bigint           not null, primary key
#  active     :boolean          default(TRUE), not null
#  name       :string(255)      not null
#  size       :decimal(10, )    default(0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Urbanization < ApplicationRecord
	has_many :sectors
	
	validates :name, presence: true
	validates :name, uniqueness: { case_sensitive: false, message: "Ya existe una urbanización con este nombre" }

	scope :actives, -> { where(active: true) }
end
