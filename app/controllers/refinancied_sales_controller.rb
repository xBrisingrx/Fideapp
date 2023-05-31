class RefinanciedSalesController < ApplicationController
  def index
    @sale = Sale.find(params[:sale_id])
  end

  def new
  end

  def create
    ActiveRecord::Base.transaction do 
      sale_refinancied = Sale.find(params[:product_id])
      sale = Sale.new(
        apply_arrear: params[:apply_arrear],
        arrear: params[:arrear],
        comment: params[:comment],
        date: params[:date],
        due_day: params[:due_day],
        number_of_payments: params[:number_of_payments],
        land_id: params[:land_id],
        price: 0 )
      if sale.save! 
        sale.sale_products.create!(product: sale_refinancied) # reg venta del producto

        if params[:num_pays].to_i > 0 # Se ingreso un primer pago
          for i in 1..params[:num_pays].to_i do  
            payments_currency_id = params["payment_currency_id_#{i}".to_sym].to_i
            taken_in = params["value_in_pesos_#{i}".to_sym].to_f
            pay = params["payment_#{i}".to_sym].to_f
            payment = sale.payments.new(
              payments_currency_id: payments_currency_id,
              payment: pay,
              taken_in: params["tomado_en_#{i}".to_sym].to_f,
              comment: params["detail_#{i}".to_sym],
              date: ( params["pay_date_#{i}".to_sym] ),
              first_pay: true
            )
            if !params["files_#{i}".to_sym].blank?
              payment.images = params["files_#{i}".to_sym]
            end
            payment.save!
          end
        end

        # Fecha de compra
        today = sale.date 

        # Fecha de vencimiento si venciera ESTE mes, en base a eso saco las siguientes fechas de vencimiento
        due_date = Time.new(today.year, today.month, sale.due_day.to_i)
        if params[:setear_cuotas_manual] == "true"
           sale.generar_cuotas_manual( params[:valores_cuota], params[:fee_start_date] )
        else
          sale.generar_cuotas( params[:number_cuota_increase].to_i, params[:valor_cuota_aumentada].to_f, params[:valor_cuota].to_f, params[:fee_start_date] )
        end
        
        sale.calculate_total_value!
        sale_refinancied.set_refinancied
        render json: {status: 'success', msg: 'Refinanciado'}, status: :ok
      else
        render json: {status: 'errors', msg: 'No se pudo registrar la venta'}, status: :unprocessable_entity
      end # save sale
    end # transaction
    rescue => e
      puts "Excepcion => #{e.message}"
      @response = e.message.split(':')
      render json: {status: 'error', msg: 'No se pudo registrar la venta'}, status: 402
  end
end
