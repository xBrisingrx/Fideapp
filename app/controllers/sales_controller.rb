class SalesController < ApplicationController
  before_action :set_sale, only: %i[ show edit update destroy ]

  def index
    @sales = Sale.all
  end

  def show
  end

  def new
    @clients = Client.select(:id, :name, :last_name).where(active: true)
    @currencies = Currency.select(:id, :name).where(active: true)
    @sale = Sale.new
    @product_type = params[:product_type]
    @product_id = params[:product_id]
    @land_id = params[:land_id]
    case @product_type
      when 'land'
         @product = Land.select(:id, :price, :code).find(@product_id) 
         @title_modal = "Venta del lote #{@product.code}"
      else 
        raise "No es un producto reconocido"
    end
  end

  def edit
  end

  def create
    return render json: {status: 'error', msg: 'No se han seleccionado clientes'}, status: 422 if params[:clients].blank?
    ActiveRecord::Base.transaction do 
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
        params[:clients].uniq # me aseguro de que no haya ningun id repetido
        params[:clients].each do |client| # Generamos los registros de los clientes que hicieron la compra
          sale.sale_clients.create!(client_id: client)
        end

        sale.sale_products.create!(product_type: params[:product_type].capitalize,product_id: params[:product_id]) # reg venta del producto

        if params[:num_pays].to_i > 0 # Se ingreso un primer pago
          cuota_cero = sale.fees.create(
            due_date: sale.date,
            pay_date: sale.date,
            value: 1,
            number:0, 
            payed: true,
            pay_status: :pagado,
            comment: "Primer entrega")

          for i in 1..params[:num_pays].to_i do 
            currency_id = params["currency_id_#{i}".to_sym].to_i
            value_in_pesos = params["value_in_pesos_#{i}".to_sym].to_f
            paid = params["payment_#{i}".to_sym].to_f
            fee_payment = cuota_cero.fee_payments.new(
              currency_id: currency_id,
              payment: paid,
              total: ( ( currency_id == 2) || ( currency_id == 3) ) ? value_in_pesos : paid,
              tomado_en: params["tomado_en_#{i}".to_sym].to_f,
              detail: params["detail_#{i}".to_sym],
              date: ( params["pay_date_#{i}".to_sym].empty? ) ? sale.date : params["pay_date_#{i}".to_sym]
            )
            if !params["files_#{i}".to_sym].blank?
              fee_payment.images = params["files_#{i}".to_sym]
            end
            fee_payment.save!
          end
          cuota_cero.calcular_primer_pago
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
        render json: {status: 'success', msg: 'Venta exitosa'}, status: :ok
      else
        render json: {status: 'errors', msg: 'No se pudo registrar la venta'}, status: :unprocessable_entity
      end # save sale
    end # transaction
    rescue => e
      puts "Excepcion => #{e.message}"
      @response = e.message.split(':')
      render json: {status: 'error', msg: 'No se pudo registrar la venta'}, status: 402
  end #create

  def update
    respond_to do |format|
      if @sale.update(sale_params)
        format.html { redirect_to sale_url(@sale), notice: "Sale was successfully updated." }
        format.json { render :show, status: :ok, location: @sale }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @sale.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @sale.destroy

    respond_to do |format|
      format.html { redirect_to sales_url, notice: "Sale was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_sale
      @sale = Sale.find(params[:id])
    end

    def sale_params
      params.require(:sale).permit(:apply_arrear, :arrear, :comment, :date, :number_of_payments, :price, :status)
    end
end
