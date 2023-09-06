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
    project = Project.find(self.project.id)
    land_price = self.project.land_price
    land_corner_price = self.project.land_corner_price
    self.apple.lands.each do |land|
      land_project = LandProject.new(project: self.project, land: land, status: :process)
      land_project.price = (land.is_corner) ? land_corner_price : land_price
      # agrego el proyecto a el lote
      land_project.save
      # genero la venta
      sale = Sale.create(
        date: project.date,
        land_id: land.id,
        number_of_payments: project.number_of_payments
      )
      #agrego el producto
      sale.sale_products.create( product: project )
      due_date = Time.new(project.date.year, project.date.month, 10)
      fee_value = (land.is_corner) ? project.price_fee_corner : project.price_fee
      # genero las cuotas
      for i in 1..project.number_of_payments
        sale.fees.create!(
          due_date: due_date, 
          value: fee_value, 
          number: i
        )
        due_date += 1.month
      end
    end
  end
end
