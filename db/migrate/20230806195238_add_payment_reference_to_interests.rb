class AddPaymentReferenceToInterests < ActiveRecord::Migration[5.2]
  def change
    add_reference :interests, :payment, foreign_key: true,comment: "Se agrega solo si el ajuste se genero al registrar un pago. Si es epago se cancela podemos cancelar este ajuste"
  end
end
