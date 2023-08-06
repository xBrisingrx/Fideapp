# == Schema Information
#
# Table name: sale_clients
#
#  id         :bigint           not null, primary key
#  sale_id    :bigint
#  client_id  :bigint
#  active     :boolean          default(TRUE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class SaleClient < ApplicationRecord
  belongs_to :sale
  belongs_to :client

  validates :client_id, uniqueness: { scope: :sale_id, message: "El cliente ya se encuentra agregado en esta venta" }
end
