# == Schema Information
#
# Table name: project_materials
#
#  id          :bigint           not null, primary key
#  project_id  :bigint
#  material_id :bigint
#  active      :boolean          default(TRUE)
#  price       :decimal(15, 2)   default(0.0)
#  porcent     :decimal(15, 2)   default(0.0)
#  units       :decimal(15, 2)   default(0.0)
#  type_units  :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class ProjectMaterial < ApplicationRecord
  belongs_to :project
  belongs_to :material

  scope :actives, -> { where( active: true) }
end
