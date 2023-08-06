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

  after_create :update_total_value_fee 

  private

  def update_total_value_fee
    self.fee.update_total_value
  end
end
