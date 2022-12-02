# == Schema Information
#
# Table name: project_materials
#
#  id          :bigint           not null, primary key
#  active      :boolean          default(TRUE)
#  porcent     :decimal(15, 2)   default(0.0)
#  price       :decimal(15, 2)   default(0.0)
#  type_units  :string(255)      not null
#  units       :decimal(15, 2)   default(0.0)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  material_id :bigint
#  project_id  :bigint
#
# Indexes
#
#  index_project_materials_on_material_id  (material_id)
#  index_project_materials_on_project_id   (project_id)
#
# Foreign Keys
#
#  fk_rails_...  (material_id => materials.id)
#  fk_rails_...  (project_id => projects.id)
#
class ProjectMaterial < ApplicationRecord
  belongs_to :project
  belongs_to :material
end
