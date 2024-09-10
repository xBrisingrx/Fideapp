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
  has_one :sale, through: :fee
  attribute :apply_to_many_fees, :boolean

  after_create :check_apply_to_many_fees_and_sale

  validates :value, 
    presence: true,
    numericality: { greater_than: 0 }

  scope :actives, ->{ where(active:true) }

  def disable
    self.update(active: false)
  end

  private
  def check_apply_to_many_fees_and_sale
    # verificamos si el ajuste se aplica a mas de una cuota
    if self.apply_to_many_fees
      number = self.fee.number
      fees = self.sale.fees.where('number > ?', number)
      fees.each do |fee|
        fee.adjusts.create( value: self.value, comment: self.comment )
      end
    end
    # actualizamos los datos de la venta asociada
    self.sale.update(status: :approved)# si la venta ya estaba pagada del todo hay que actualizar el estado
    self.sale.calculate_total_value!
    self.sale.update_payment_status #actualizo el estado de pago de esta venta
  end
end
