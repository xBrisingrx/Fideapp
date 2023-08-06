# == Schema Information
#
# Table name: sectors
#
#  id              :bigint           not null, primary key
#  name            :string(255)      not null
#  active          :boolean          default(TRUE), not null
#  size            :decimal(10, )    default(0), not null
#  urbanization_id :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class Sector < ApplicationRecord
	belongs_to :urbanization
	has_many :apples
	
	validates :name, presence: true, 
		uniqueness: { scope: :urbanization_id, case_sensitive: false, message: "Ya existe un sector con este nombre en esta urbanización" }

	scope :actives, -> { where(active: true) }
end
