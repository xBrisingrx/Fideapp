# == Schema Information
#
# Table name: apple_projects
#
#  id         :bigint           not null, primary key
#  apple_id   :bigint
#  project_id :bigint
#  active     :boolean          default(TRUE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class AppleProject < ApplicationRecord
  # Esta manzana que proyectos tiene 
  belongs_to :apple
  belongs_to :project

  after_create :create_land_projects

  private

  def create_land_projects
    land_price = self.project.land_price
    land_corner_price = self.project.land_corner_price

    self.apple.lands.each do |land|
      land_project = LandProject.new(project: self.project, land: land, status: :pending)
      land_project.price = (land.is_corner) ? land_corner_price : land_price
      land_project.save
    end
  end
end
