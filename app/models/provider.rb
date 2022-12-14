# == Schema Information
#
# Table name: providers
#
#  id          :bigint           not null, primary key
#  active      :boolean          default(TRUE)
#  activity    :string(255)
#  cuit        :string(255)
#  description :string(255)
#  name        :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Provider < ApplicationRecord
	validates :name, presence: true
	scope :actives, -> { where(active: true) }
end
