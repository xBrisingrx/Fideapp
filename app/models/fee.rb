# == Schema Information
#
# Table name: fees
#
#  id                                               :bigint           not null, primary key
#  active                                           :boolean          default(TRUE)
#  comment                                          :string(255)      default("")
#  due_date                                         :date
#  interest(Interes)                                :decimal(15, 2)   default(0.0), not null
#  number                                           :integer          not null
#  owes(Lo que adeuda)                              :decimal(15, 2)   default(0.0), not null
#  pay_date                                         :date
#  pay_status                                       :integer          default("pendiente")
#  payed                                            :boolean          default(FALSE)
#  payment(Valor pagado)                            :decimal(15, 2)   default(0.0), not null
#  total_value(Valor inicial + ajustes + intereses) :decimal(15, 2)   default(0.0), not null
#  value(Valor inicial)                             :decimal(15, 2)   default(0.0), not null
#  created_at                                       :datetime         not null
#  updated_at                                       :datetime         not null
#  sale_id                                          :bigint
#
# Indexes
#
#  index_fees_on_sale_id  (sale_id)
#
# Foreign Keys
#
#  fk_rails_...  (sale_id => sales.id)
#
class Fee < ApplicationRecord
  belongs_to :sale
  has_many :fee_payments, dependent: :destroy

  scope :actives, -> { where(active: true) }
  scope :no_cero, -> { where( "number > 0" ) }
  scope :no_payed, -> { where.not(pay_status: :pagado) }

  enum pay_status: [:pendiente, :pagado, :pago_parcial]

  def calcular_primer_pago
    primer_pago = self.fee_payments.sum(:total)
    self.update( payment: primer_pago , value: primer_pago ,total_value: primer_pago )
  end

  def expired?
    self.due_date.strftime("%F")  < Time.new.strftime("%F") 
  end
end
