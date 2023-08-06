class PaymentsController < ApplicationController
  before_action :set_payment, only: %i[ show edit update destroy ]

  # controlador de los pagos que se realizan
  def index
    @payments = Payment.all
  end

  # GET /payments/1 or /payments/1.json
  def show
  end

  # GET /payments/new
  def new
    @title_modal = 'Registrar pago'
    @sale_id = params[:sale_id]
    current_month = Time.new.month
    @fee = Fee.find(params[:fee_id]) #obtengo la cuota que corresponde pagar 
    @fee_total_value = @fee.total_value
    @adeuda = @fee.get_deuda_cuotas_anteriores
    @apply_arrear = @fee.apply_arrear?
    @payments_currencies = PaymentsCurrency.actives
    if @apply_arrear
      # fecha primer cuota vencima
      # @due_date = @fee.get_due_date_sale
      # El % que se seteo cuando se hizo la venta
      @porcentaje_interes = @fee.sale.arrear
      @fecha_primer_cuota_impaga = @fee.sale.fecha_inicio_interes
      # Esto es el valor calculado del interes diario
      @interes_diario = @fee.interes_diario
      @interes_sugerido = @fee.calcular_interes
      @total_a_pagar = ( @interes_sugerido + @adeuda + @fee.total_value ).round(2)
    else
      @porcentaje_interes = 0
      @total_a_pagar = ( @adeuda + @fee.total_value ).round(2)
    end
    @payment = Payment.new
  end

  # GET /payments/1/edit
  def edit
  end

  # POST /payments or /payments.json
  def create
    ActiveRecord::Base.transaction do 
      # payment es lo que se pago, ese valor viene en calculo_en_pesos
      # cuota.payment = params[:calculo_en_pesos].to_f
      sale = Sale.find(params[:payment][:sale_id])
      fee = Fee.current_fee( sale.id, params[:payment][:date].to_time )
      if params[:interest].to_f > 0 # chequeamos si se le sumo intereses
        # discrimino el interes aplicado en la cuota
        fee.interests.create(value: params[:interest].to_f, date: params[:payment][:date], comment: 'Mora por pago fuera de termino.')
      end

      if params[:adjust].to_f > 0 # Si agregaron algo al ajuste 
        fee.adjusts.create(value:  params[:adjust].to_f, comment:  params[:comment_adjust], date: params[:payment][:date])
      end

      payment = Payment.new(payment_params)

      if payment.save
        render json: { status: 'success', msg: 'Pago registrado' }, status: 200
      else
        render json: { status: 'error', msg: 'No se pudo registrar el pago' }, status: 422
      end
    end # transaction
    rescue => e
      @response = e.message.split(':')
      puts @response
      render json: { status: 'error', msg: 'Error del sistema' }, status: 402
  end

  # PATCH/PUT /payments/1 or /payments/1.json
  def update
    respond_to do |format|
      if @payment.update(payment_params)
        format.html { redirect_to payment_url(@payment), notice: "Payment was successfully updated." }
        format.json { render :show, status: :ok, location: @payment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payments/1 or /payments/1.json
  def destroy
    @payment.destroy

    respond_to do |format|
      format.html { redirect_to payments_url, notice: "Payment was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment
      @payment = Payment.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def payment_params
      params.require(:payment).permit(:sale_id, :date, :payment, :payments_currency_id, :total, :taken_in, :active, :comment, images:[])
    end
end
