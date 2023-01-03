class AddNeedExchangeToCurrencies < ActiveRecord::Migration[5.2]
  def change
    add_column :currencies, :need_exchange, :boolean, default: false
  end
end
