# == Schema Information
#
# Table name: sale_products
#
#  id           :bigint           not null, primary key
#  sale_id      :bigint
#  product_type :string(255)
#  product_id   :bigint
#  comment      :text(65535)
#  active       :boolean          default(TRUE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class SaleProduct < ApplicationRecord
	belongs_to :sale
  belongs_to :product, polymorphic: true

  after_create :update_product_status

  def update_product_status
    case self.product_type
      when 'Land'
        product = Land.find self.product_id
        product.update(status: :bought)
      when 'Sale' #refinanciacion
        sale = Sale.find( self.product_id )
        if sale.sale_products.first.product_type != 'Land'
          # byebug
          #hay que ver si tiene sentido ponerlos otra vez en proceso
          # project = LandProject.where(project_id: self.product_id, land_id: self.sale.land_id ).first
          # project.update(status: :process)
        end
      when 'Project'
        project = LandProject.where(project_id: self.product_id, land_id: self.sale.land_id ).first
        project.update(status: :process)
      else
        raise "Producto invalido"
    end
  end
  
end
