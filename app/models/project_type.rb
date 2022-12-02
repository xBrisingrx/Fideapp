# == Schema Information
#
# Table name: project_types
#
#  id          :bigint           not null, primary key
#  active      :boolean          default(TRUE)
#  description :string(255)      default("")
#  name        :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class ProjectType < ApplicationRecord
	validates :name, presence: true

	scope :actives, -> { where(active: true) }
end
