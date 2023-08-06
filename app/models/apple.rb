# == Schema Information
#
# Table name: apples
#
#  id                  :bigint           not null, primary key
#  code                :string(100)      not null
#  hectares            :decimal(15, 2)   default(0.0), not null
#  value               :decimal(15, 2)   default(0.0), not null
#  space_not_available :decimal(15, 2)   default(0.0)
#  condominium_id      :bigint
#  sector_id           :bigint
#  active              :boolean          default(TRUE), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
class Apple < ApplicationRecord
  belongs_to :condominium
  belongs_to :sector
  has_many :lands
  has_one :urbanization, through: :sector
  has_one_attached :blueprint

  validates :code, presence: true,
    uniqueness: {  scope: :sector_id, case_sensitive: false, message: "Ya existe una manzana con esta denominación en este sector" }

  scope :actives, -> { where(active: true) }

  def has_corner
    self.lands.where(is_corner: true).count > 0
  end

  def count_corners
    self.lands.where(is_corner: true).count
  end

  def get_all_pay
    all_pay = 0 
    self.lands.each do |land|
      all_pay += land.get_all_pay
    end
    all_pay
  end

  def get_all_owes
    all_owes = 0 
    self.lands.each do |land|
      all_owes += land.get_all_owes
    end
    all_owes
  end

  def total_price
    total_price = 0
    self.lands.each do |land|
      total_price += land.total_price
    end
    total_price
  end

  def owes_this_month
    pay_this_month = 0
    self.lands.each do |land|
      pay_this_month += land.owes_this_month
    end
    pay_this_month
  end
end
