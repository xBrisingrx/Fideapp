class AddFirstPayRequiredToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :first_pay_required, :boolean, default:true
    add_column :projects, :first_pay_price, :decimal,precision: 15, scale: 2, comment: "Valor si se necesita una primer entrega"
  end
end
