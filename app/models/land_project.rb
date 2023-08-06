# == Schema Information
#
# Table name: land_projects
#
#  id         :bigint           not null, primary key
#  land_id    :bigint
#  project_id :bigint
#  status     :integer
#  price      :decimal(15, 2)   default(0.0)
#  porcent    :decimal(15, 2)   default(0.0)
#  active     :boolean          default(TRUE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class LandProject < ApplicationRecord
  # Esta tierra que proyectos tiene
  belongs_to :land
  belongs_to :project

  validates :price, 
    presence: true, 
    numericality: { greater_than: 0 }

  validates :status, presence: true

  enum status: [:pending, :process, :payed, :refinancied]
end
