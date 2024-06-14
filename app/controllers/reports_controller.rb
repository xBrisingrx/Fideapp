class ReportsController < ApplicationController

  def land_payments
    land = Land.find(params[:land_id])
    @payments = land.get_payments(params[:start_date], params[:end_date])
    @column_titles = ['Urbanizacion', 'Sector', 'Fecha', 'Manzana', 'Lote', 'Que pago' , 'Cliente', 'Monto']
    @letter_title = get_letter( @column_titles.count )
    @title = "Pagos lote #{land.code}"
    respond_to do |format|
			format.xlsx {
		    render xlsx: "reports/land_payments", disposition: "attachment", filename: "pagos_lote_#{land.code}.xlsx"
		  }
		end
  end

  def apple_payments
    apple = Apple.find(params[:apple_id])
    @lands = apple.lands
    @column_titles = ['Urbanizacion', 'Sector', 'Fecha', 'Manzana', 'Lote', 'Que pago' , 'Cliente', 'Monto']
    @letter_title = get_letter( @column_titles.count )
    @title = "Pagos lote #{apple.code}"
    respond_to do |format|
			format.xlsx {
		    render xlsx: "reports/apple_payments", disposition: "attachment", filename: "pagos_manzana_#{apple.code}.xlsx"
		  }
		end
  end

  def get_letter number
		h = {}
		('A'..'ZZZ').each_with_index{|w, i| h[i+1] = w }
		h[number]
	end
end