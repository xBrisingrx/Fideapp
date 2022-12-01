# == Schema Information
#
# Table name: condominia
#
#  id          :bigint           not null, primary key
#  active      :boolean          default(TRUE)
#  description :string(255)
#  name        :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Condominium < ApplicationRecord
	validates :name, presence: true, uniqueness: { case_sensitive: false, message: "Ya existe una condominio con este nombre" }

	scope :actives, -> { where(active: true) }
end
