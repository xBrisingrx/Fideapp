# == Schema Information
#
# Table name: adjusts
#
#  id         :bigint           not null, primary key
#  value      :decimal(15, 2)   default(0.0)
#  porcent    :decimal(15, 2)   default(0.0)
#  active     :boolean          default(TRUE)
#  comment    :string(255)
#  fee_id     :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  date       :date
#  payment_id :bigint
#
class Adjust < ApplicationRecord
  belongs_to :fee
  # Ligamos al payment solo cuando se genera al pagar una cuota
  # con eso ganamos que al eliminar un pago se elimina esta mora 
  belongs_to :payment, optional: true

  # after_create :update_total_value_fee 

  validates :value, 
    presence: true,
    numericality: { greater_than: 0 }
  scope :actives, ->{ where(active:true) }
  def disable
    self.update(active: false)
  end
  private

  # def update_total_value_fee
  #   self.fee.update_total_value
  # end
end
