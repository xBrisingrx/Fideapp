# == Schema Information
#
# Table name: price_adjustments
#
#  id         :bigint           not null, primary key
#  active     :boolean          default(TRUE)
#  comment    :string(255)
#  date       :date             not null
#  value      :decimal(15, 2)   default(0.0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class PriceAdjustment < ApplicationRecord
end
