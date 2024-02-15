# == Schema Information
#
# Table name: provider_roles
#
#  id          :bigint           not null, primary key
#  active      :boolean          default(TRUE)
#  description :string(255)
#  name        :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class ProviderRole < ApplicationRecord
	validates :name, presence: true, 
		uniqueness: { case_sensitive: false, message: "Este rol ya se encuentra registrdo" }
		scope :actives, -> { where( active: true) }
end
