# == Schema Information
#
# Table name: payment_plans
#
#  id         :bigint           not null, primary key
#  project_id :bigint
#  number     :integer          not null
#  option     :integer          not null
#  category   :integer          not null
#  price      :decimal(15, 2)   not null
#  date       :date             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class PaymentPlan < ApplicationRecord
  belongs_to :project
  validates :number, :option, :category, :price, :date, presence: true
end
