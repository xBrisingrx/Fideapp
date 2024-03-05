# == Schema Information
#
# Table name: lands
#
#  id                  :bigint           not null, primary key
#  code                :string(255)      not null
#  is_corner           :boolean          default(FALSE)
#  is_green_space      :boolean          default(FALSE)
#  land_type           :integer          default(0)
#  measure             :string(255)
#  price               :decimal(15, 2)   default(0.0)
#  space_not_available :decimal(15, 2)   default(0.0)
#  status              :integer          default("available")
#  area                :decimal(15, 2)   default(0.0)
#  ubication           :string(255)
#  apple_id            :bigint
#  active              :boolean          default(TRUE)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
class Land < ApplicationRecord
  belongs_to :apple
  has_one :sector, through: :apple
  has_many :sales
  has_many :sale_products, through: :sales
  has_many :sale_clients, through: :sales 
  has_many :land_projects
  has_one_attached :blueprint

  validates :code, 
    presence: true,
    uniqueness: { scope: :apple_id,case_sensitive: false, message: "Ya existe un lote con esta denominación" }

  enum status: [:available, :bought, :canceled]

  # after_create :projects_in_apple

  def land_sale_date
    sp = SaleProduct.where(product_type: :Land, product_id: self.id ).first
    sp.sale.date.strftime('%d-%m-%y')
  end

  def total_price
    # obtenemos el valor de este lote que es valor
    # si total_price es CERO significa que todavia no se vendio nada del lote (tierra, proyectos)
    # si no es cero, el valor del lote es valor tierra + valor proyectos 
    total_price = 0 
    self.sale_products.each do |product|
      total_price += product.sale.total_value
    end

    return ( total_price  > 0 ) ? total_price : self.price
  end

  def get_all_pay
    total_pay = 0
    self.sales.each do |sale|
      total_pay +=  sale.saldo_pagado
    end
    total_pay
  end

  def get_all_owes
    total_owes = 0
    self.sales.each do |sale|
      total_owes +=  sale.total_value - sale.saldo_pagado
    end
    total_owes
  end

  def projects_not_aprobed
    self.land_projects.where(status: :pending).count > 0
  end

  def land_sale
    # obtenemos la venta de tierra
    self.sale_products.where(product_type: 'Land').first
  end

  def reset_status
    self.update(status: :available)
  end

  def owes_this_month
    pay_this_month = 0
    self.sales.each do |sale|
      pay_this_month += sale.owes_this_month
    end
    pay_this_month
  end

  def paid_this_month
    paid = 0
    self.sales.each do |sale|
      paid += sale.paid_this_month
    end
    paid
  end

  def get_all_increments
    increments = 0
    self.sales.each do |sale|
      increments +=  sale.get_increments
    end
    increments
  end

  def get_value
    land_value = 0
    self.sales.each do |sale|
      land_value += sale.get_value
    end
    land_value
  end

end
