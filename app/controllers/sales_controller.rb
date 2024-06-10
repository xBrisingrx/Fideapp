class SalesController < ApplicationController
  before_action :set_sale, only: %i[ show edit update destroy set_payment_plan ]

  def index
    @sales = Sale.all
  end

  def show;end

  def new
    @cant = 0
    @clients = Client.select(:id, :name, :last_name).where(active: true).order(:name)
    @currencies = Currency.select(:id, :name).where(active: true)
    @payments_types = PaymentsType.actives
    @cp = PaymentsCurrency.actives
    @sale = Sale.new(due_day: 10)
    @product_type = params[:product_type].capitalize
    @product_id = params[:product_id]
    @land_id = params[:land_id]
    # land = Land.find params[:land_id]
    case @product_type
      when 'Land'
         @product = Land.select(:id, :price, :code).find_by(id: @product_id) 
         @title_modal = "Venta del lote #{@product.code}"
         @is_land_sale = true
      when 'Project'
        @product = Project.find @product_id
        @title_modal = "Proyecto: #{@product.project_type.name}"
        land_project = LandProject.where(land_id: params[:land_id], project_id: @product.id ).first
        @price = land_project.price
        render :sale_project
      when 'Sale'
        @product = Sale.select(:id, :price, :refinanced).find(@product_id)
        @title_modal = "Refinanciación"
        @price = @product.get_all_owes
        render :sale_project
      else 
        raise "No es un producto reconocido"
    end
  end

  def create
    sale = Sale.new(sale_params)
    ActiveRecord::Base.transaction do 
      if sale.save
        render json: {status: 'success', msg: 'Venta exitosa'}, status: :ok
      else
        render json: {status: 'errors', msg: 'No se pudo registrar la venta'}, status: :unprocessable_entity
      end
    end # transaction
    rescue => e
      @response = e.message.split(':')
      render json: {status: 'error', msg: 'No se pudo registrar la venta'}, status: 402
  end

  def edit
    project = Project.find @sale.sale_products.first.product.id
    @project_price = project.land_price
    @quantity_plans = project.payment_plans.group(:option).count.count
    @first_pays = project.payment_plans.where( category: 1 )
    @quotes = project.payment_plans.where( category: 2 )
    @cp = PaymentsCurrency.actives
  end

  def update
    if @sale.update( sale_params )
      render json: {status: 'success', msg: 'Proyecto financiado.'}, status: :ok
    else
      render json: {status: 'errors', msg: 'No se pudo financiar el proyecto'}, status: :unprocessable_entity
    end
  end

  def set_payment_plan
    if @sale.update(date: params[:sale][:date]) && @sale.set_payment_plan( params[:payment_plan][:option] )
      render json: {status: 'success', msg: 'Proyecto financiado.'}, status: :ok
    else
      render json: {status: 'errors', msg: 'No se pudo financiar el proyecto'}, status: :unprocessable_entity
    end
  end

  def sale_project
    sale = Sale.new(
      comment: params[:comment],
      date: params[:date],
      due_day: params[:due_day],
      number_of_payments: params[:number_of_payments],
      land_id: params[:land_id],
      price: 0 )
    if sale.save! 
      sale.sale_products.create!(product_type: params[:product_type].capitalize,
        product_id: params[:product_id]) # reg venta del producto

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
    end # end sale save
  end
  
  def destroy 
    sale = Sale.find params[:id]
    case sale.sale_products.first.product_type
    when 'Land'
      product = Land.find sale.sale_products.first.product_id
    end

    ActiveRecord::Base.transaction do 
      if sale.destroy && product.reset_status
        render json: {status: 'success', msg: 'Se elimino la venta'}, status: :ok 
      else
        render json: {status: 'errors', msg: 'Ocurrio un error eliminando esta venta'}, status: :unprocessable_entity
      end
    end
    rescue => e
      puts "Excepcion => #{e.message}"
      @response = e.message.split(':')
      render json: {status: 'error', msg: 'Error: no se pudo realizar la eliminacion de venta'}, status: 402
  end

  def payment_summary
    sale = Sale.find params[:id]
    @payments = ''
    @fees = sale.fees 
    @first_payments = sale.payments.is_first_pay.actives
    @row_color = 'table-active'
    @cant_payments = 0
  end

  private
    def set_sale
      @sale = Sale.find(params[:id])
    end

    def sale_params
      params.require(:sale).permit(:comment, :date, :number_of_payments, 
          :price, :status, :refinanced, :land_id, :due_day, :land_sale, :land_price,
        sale_clients_attributes: [:id, :client_id],
        sale_products_attributes: [:id, :product_id, :product_type],
        fees_attributes: [:id, :number,:value, :due_date],
        payments_attributes: [:id,:payments_currency_id,:payment,:taken_in,:comment,:date,:first_pay, files:[] ])
    end
end