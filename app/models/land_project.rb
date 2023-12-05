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
  attribute :price_quotas
  attribute :price_quotas_corner
  belongs_to :land
  belongs_to :project

  validates :price, 
    presence: true, 
    numericality: { greater_than: 0 }

  validates :status, presence: true

  after_create :create_sale

  enum status: [:pending, :process, :payed, :refinancied]

  private
  def create_sale
    project = Project.find(self.project_id)
    land = Land.find(self.land_id)
    number_of_payments = project.number_of_payments
    sale = Sale.create(
      date: project.date,
      land_id: land.id,
      number_of_payments: number_of_payments
    )
    # I add product to sale
    sale.sale_products.create( product: project )
    due_date = Time.new(project.date.year, project.date.month, 10)

    if project.first_pay_required
      sale.fees.create!(
        due_date: project.date, 
        value: project.first_pay_price, 
        number: 0
      )
    end
    
    if self.price_quotas != [""]
      # cada cuota tiene un valor diferente
      fee_value = (land.is_corner) ? self.price_quotas_corner[0].split(',') : self.price_quotas[0].split(',')
      for i in 1..number_of_payments
        sale.fees.create!(
          due_date: due_date, 
          value: fee_value[i - 1].to_f, 
          number: i
        )
        due_date += 1.month
      end
    else
      fee_value = (land.is_corner) ? project.price_fee_corner : project.price_fee
      # I create fees
      for i in 1..number_of_payments
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
