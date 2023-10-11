# == Schema Information
#
# Table name: projects
#
#  id                :bigint           not null, primary key
#  number            :integer          not null
#  name              :string(255)
#  active            :boolean          default(TRUE)
#  price             :decimal(15, 2)   default(0.0), not null
#  subtotal          :decimal(15, 2)   default(0.0), not null
#  final_price       :decimal(15, 2)   default(0.0), not null
#  status            :integer          default("pendiente")
#  description       :text(65535)
#  land_price        :decimal(15, 2)   default(0.0), not null
#  land_corner_price :decimal(15, 2)   default(0.0), not null
#  project_type_id   :bigint
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  date              :date             default(Sun, 01 Jan 2023), not null
#
class Project < ApplicationRecord
  attribute :finalized, :boolean

	has_many :project_providers, dependent: :destroy
  has_many :project_materials, dependent: :destroy
  has_many :land_projects, dependent: :destroy
  has_many :apple_projects, dependent: :destroy
  belongs_to :project_type

  has_many :providers, through: :project_providers
  has_many :materials, through: :project_materials
  has_many :lands, through: :land_projects

  accepts_nested_attributes_for :project_providers, :project_materials,:apple_projects

  validates :land_price, :land_corner_price, 
    presence: true, 
    numericality: { greater_than: 0 }
  validates :number, presence: true, numericality: { only_integer: true }
  validates :date, presence: true
  
  after_create :check_is_finalized

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
  
  private
  def check_is_finalized
    # if this priject is created with finalized in true means that
    # it's a old project and was paid. Then I must create the land_projects paid and with one quote
    if self.finalized
      self.land_projects.update_all( status: :payed )
      sale_products = SaleProduct.where(product: self)
      sale_products.each do |sale_product|
        # get fee to pay
        sale = sale_product.sale
        pay = sale.fees.first.value
        sale.payments.create(
          date: self.date,
          payments_currency_id: 1,
          payment: pay,
          taken_in: 1,
          total: pay,
          comment: "Pago completo del projecto."
        )
        sale.fees.first.update(pay_status: :pagado, payed: true, payment: pay, pay_date: self.date)
        sale.update(status: :payed)
        byebug
      end
      self.update(status: :terminado)
    end
  end
end
