# == Schema Information
#
# Table name: materials
#
#  id          :bigint           not null, primary key
#  active      :boolean          default(TRUE)
#  description :string(255)
#  name        :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Material < ApplicationRecord
	validates :name, presence: true
	scope :actives, -> { where(active: true) }
end
