# == Schema Information
#
# Table name: projects
#
#  id                                                :bigint           not null, primary key
#  active                                            :boolean          default(TRUE)
#  description                                       :text(65535)
#  final_price                                       :decimal(15, 2)   default(0.0), not null
#  land_corner_price(Precio por lote que es esquina) :decimal(15, 2)   default(0.0), not null
#  land_price(Precio por lote)                       :decimal(15, 2)   default(0.0), not null
#  name                                              :string(255)
#  number                                            :integer          not null
#  price                                             :decimal(15, 2)   default(0.0), not null
#  status                                            :integer          default("proceso")
#  created_at                                        :datetime         not null
#  updated_at                                        :datetime         not null
#  project_type_id                                   :bigint
#
# Indexes
#
#  index_projects_on_project_type_id  (project_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_type_id => project_types.id)
#
class Project < ApplicationRecord
	has_many :project_providers
  has_many :project_materials

  has_many :providers, through: :project_providers
  has_many :materials, through: :project_materials

  scope :actives, -> { where(active: true) }
  
  enum status: [:proceso, :terminado]
end
