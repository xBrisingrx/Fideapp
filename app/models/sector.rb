# == Schema Information
#
# Table name: sectors
#
#  id              :bigint           not null, primary key
#  active          :boolean          default(TRUE), not null
#  name            :string(255)      not null
#  size            :decimal(10, )    default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  urbanization_id :bigint
#
# Indexes
#
#  index_sectors_on_urbanization_id  (urbanization_id)
#
# Foreign Keys
#
#  fk_rails_...  (urbanization_id => urbanizations.id)
#
class Sector < ApplicationRecord
	belongs_to :urbanization
	has_many :apples
	
	validates :name, presence: true, 
		uniqueness: { scope: :urbanization_id, case_sensitive: false, message: "Ya existe un sector con este nombre en esta urbanización" }

	scope :actives, -> { where(active: true) }
end
