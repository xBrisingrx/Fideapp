# == Schema Information
#
# Table name: project_providers
#
#  id                                                                                                                    :bigint           not null, primary key
#  active                                                                                                                :boolean          default(TRUE)
#  iva                                                                                                                   :decimal(15, 2)   default(0.0)
#  porcent(% que cobra)                                                                                                  :decimal(15, 2)   default(0.0)
#  price(Precio que cobra)                                                                                               :decimal(15, 2)   default(0.0)
#  price_calculate(Precio calculado cuando el proveedor cobra por porcentaje de obra)                                    :decimal(15, 2)   default(0.0)
#  type_total(El proveedor puede calcular su precio por el subtotal de la obra o por el precio valor inicial de la obra) :string(255)
#  value_iva(El valor en pesos del IVA)                                                                                  :decimal(15, 2)   default(0.0)
#  created_at                                                                                                            :datetime         not null
#  updated_at                                                                                                            :datetime         not null
#  payment_method_id                                                                                                     :bigint
#  project_id                                                                                                            :bigint
#  provider_id                                                                                                           :bigint
#  provider_role_id                                                                                                      :bigint
#
# Indexes
#
#  index_project_providers_on_payment_method_id  (payment_method_id)
#  index_project_providers_on_project_id         (project_id)
#  index_project_providers_on_provider_id        (provider_id)
#  index_project_providers_on_provider_role_id   (provider_role_id)
#
# Foreign Keys
#
#  fk_rails_...  (payment_method_id => payment_methods.id)
#  fk_rails_...  (project_id => projects.id)
#  fk_rails_...  (provider_id => providers.id)
#  fk_rails_...  (provider_role_id => provider_roles.id)
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
