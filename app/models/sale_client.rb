# == Schema Information
#
# Table name: sale_clients
#
#  id         :bigint           not null, primary key
#  active     :boolean          default(TRUE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  client_id  :bigint
#  sale_id    :bigint
#
# Indexes
#
#  index_sale_clients_on_client_id  (client_id)
#  index_sale_clients_on_sale_id    (sale_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (sale_id => sales.id)
#
class SaleClient < ApplicationRecord
  belongs_to :sale
  belongs_to :client

  validates :client_id, uniqueness: { scope: :sale_id, message: "El cliente ya se encuentra agregado en esta venta" }
end
