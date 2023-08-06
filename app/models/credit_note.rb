# == Schema Information
#
# Table name: credit_notes
#
#  id             :bigint           not null, primary key
#  date           :date             not null
#  description    :string(255)      not null
#  fee_payment_id :bigint
#  sale_id        :bigint
#  user_id        :bigint
#  active         :boolean          default(TRUE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  payment_id     :bigint
#
class CreditNote < ApplicationRecord
  belongs_to :fee_payment, optional: true
  belongs_to :payment
  belongs_to :sale
  belongs_to :user

  validates :description, presence: true

  before_create :disable_payment 

  private

  def disable_payment
    self.payment.disable  
  end
end
