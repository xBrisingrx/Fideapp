# == Schema Information
#
# Table name: project_providers
#
#  id                :bigint           not null, primary key
#  project_id        :bigint
#  provider_id       :bigint
#  payment_method_id :bigint
#  provider_role_id  :bigint
#  type_total        :string(255)
#  porcent           :decimal(15, 2)   default(0.0)
#  iva               :decimal(15, 2)   default(0.0)
#  value_iva         :decimal(15, 2)   default(0.0)
#  price             :decimal(15, 2)   default(0.0)
#  price_calculate   :decimal(15, 2)   default(0.0)
#  active            :boolean          default(TRUE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class ProjectProvider < ApplicationRecord
  belongs_to :project
  belongs_to :provider
  belongs_to :payment_method
  belongs_to :provider_role

  scope :intervinientes, -> { where( type_total: :price ) }
  scope :otros_intervinientes, -> { where( type_total: :subtotal ) }
  scope :actives, -> { where(active: true) }
  # este campo me indica en base a que saca su valor calculado
  # si es SUBTOTAL es xq lo sacamos en base a precio_projecto + materiales + precio proveedores
  # si es PRICE es xq lo sacamos en base a precio_projecto
  # enum type_total: [:price, :subtotal] 
end
