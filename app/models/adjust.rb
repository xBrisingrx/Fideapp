# == Schema Information
#
# Table name: adjusts
#
#  id         :bigint           not null, primary key
#  active     :boolean          default(TRUE)
#  comment    :string(255)
#  porcent    :decimal(15, 2)   default(0.0)
#  value      :decimal(15, 2)   default(0.0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  fee_id     :bigint
#
# Indexes
#
#  index_adjusts_on_fee_id  (fee_id)
#
# Foreign Keys
#
#  fk_rails_...  (fee_id => fees.id)
#
class Adjust < ApplicationRecord
  belongs_to :fee
end
