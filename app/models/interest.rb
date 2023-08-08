# == Schema Information
#
# Table name: interests
#
#  id             :bigint           not null, primary key
#  date           :date             not null
#  value          :decimal(15, 2)   not null
#  fee_payment_id :bigint
#  active         :boolean          default(TRUE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  fee_id         :bigint
#  comment        :text(65535)
#  payment_id     :bigint
#
class Interest < ApplicationRecord
  belongs_to :fee_payment, optional: true
  belongs_to :fee
  # Ligamos al payment solo cuando se genera al pagar una cuota
  # con eso ganamos que al eliminar un pago se elimina esta mora 
  belongs_to :payment, optional: true 

  validates :value, 
    presence: true,
    numericality: { greater_than: 0 }
  scope :actives, ->{ where(active:true) }
  def disable
    self.update(active: false)
  end
end
