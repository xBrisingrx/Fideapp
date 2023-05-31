# == Schema Information
#
# Table name: credit_notes
#
#  id             :bigint           not null, primary key
#  active         :boolean          default(TRUE)
#  date           :date             not null
#  description    :string(255)      not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  fee_payment_id :bigint
#  sale_id        :bigint
#  user_id        :bigint
#
# Indexes
#
#  index_credit_notes_on_fee_payment_id  (fee_payment_id)
#  index_credit_notes_on_sale_id         (sale_id)
#  index_credit_notes_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (fee_payment_id => fee_payments.id)
#  fk_rails_...  (sale_id => sales.id)
#  fk_rails_...  (user_id => users.id)
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
