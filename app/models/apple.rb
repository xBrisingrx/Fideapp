# == Schema Information
#
# Table name: apples
#
#  id                                                                    :bigint           not null, primary key
#  active                                                                :boolean          default(TRUE), not null
#  code                                                                  :string(100)      not null
#  hectares                                                              :decimal(15, 2)   default(0.0), not null
#  space_not_available(Espacio de la manzana que no puede ser utilizado) :decimal(15, 2)   default(0.0)
#  value                                                                 :decimal(15, 2)   default(0.0), not null
#  created_at                                                            :datetime         not null
#  updated_at                                                            :datetime         not null
#  condominium_id                                                        :bigint
#  sector_id                                                             :bigint
#
# Indexes
#
#  index_apples_on_condominium_id  (condominium_id)
#  index_apples_on_sector_id       (sector_id)
#
# Foreign Keys
#
#  fk_rails_...  (condominium_id => condominia.id)
#  fk_rails_...  (sector_id => sectors.id)
#
class Apple < ApplicationRecord
  belongs_to :condominium
  belongs_to :sector
  has_one :urbanization, through: :sector
  has_one_attached :blueprint

  validates :code, presence: true,
    uniqueness: {  scope: :sector_id, case_sensitive: false, message: "Ya existe una manzana con esta denominación en este sector" }

  scope :actives, -> { where(active: true) }

end
