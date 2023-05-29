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
#  status                                            :integer          default("pendiente")
#  subtotal                                          :decimal(15, 2)   default(0.0), not null
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
  has_many :land_projects
  belongs_to :project_type

  has_many :providers, through: :project_providers
  has_many :materials, through: :project_materials
  has_many :lands, through: :land_projects

  scope :actives, -> { where(active: true) }
  
  enum status: [:pendiente, :proceso, :terminado]

  def sector_name
    if !self.lands.empty?
      self.lands.first.sector.name
    end
  end

  def project_status
    lands = self.land_projects.count
    pending = self.land_projects.where(status: :pending).count
    process = self.land_projects.where(status: :process).count
    payed = self.land_projects.where(status: :payed).count
    status_label = ''

    if lands == pending
      status_label = 'Pendiente'
    end

    if process > 0
      status_label = 'En proceso'
    end

    if lands == payed
      status_label = 'Completado'
    end

    status_label
  end

end
