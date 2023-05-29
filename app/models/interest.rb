# == Schema Information
#
# Table name: interests
#
#  id             :bigint           not null, primary key
#  active         :boolean          default(TRUE)
#  date           :date             not null
#  value          :decimal(15, 2)   not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  fee_id         :bigint
#  fee_payment_id :bigint
#
# Indexes
#
#  index_interests_on_fee_id          (fee_id)
#  index_interests_on_fee_payment_id  (fee_payment_id)
#
# Foreign Keys
#
#  fk_rails_...  (fee_id => fees.id)
#  fk_rails_...  (fee_payment_id => fee_payments.id)
#
class Interest < ApplicationRecord
  belongs_to :fee_payment, optional: true
  belongs_to :fee
end
