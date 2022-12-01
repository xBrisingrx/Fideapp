# == Schema Information
#
# Table name: lands
#
#  id                                                                 :bigint           not null, primary key
#  active                                                             :boolean          default(TRUE)
#  area                                                               :decimal(15, 2)   default(0.0)
#  code(denominacion)                                                 :string(255)      not null
#  is_corner                                                          :boolean          default(FALSE)
#  is_green_space                                                     :boolean          default(FALSE)
#  land_type                                                          :integer
#  measure                                                            :string(255)
#  price                                                              :decimal(15, 2)   default(0.0)
#  space_not_available(Espacio de el lote que no puede ser utilizado) :decimal(15, 2)   default(0.0)
#  status                                                             :integer          default(0)
#  ubication                                                          :string(255)
#  created_at                                                         :datetime         not null
#  updated_at                                                         :datetime         not null
#  apple_id                                                           :bigint
#
# Indexes
#
#  index_lands_on_apple_id  (apple_id)
#
# Foreign Keys
#
#  fk_rails_...  (apple_id => apples.id)
#
class Land < ApplicationRecord
  belongs_to :apple
  has_one_attached :blueprint

  validates :code, 
    presence: true,
    uniqueness: { scope: :apple_id,case_sensitive: false, message: "Ya existe un lote con esta denominación" }

  enum status: [:available, :bought, :canceled]

end
