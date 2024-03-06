class PaymentsController < ApplicationController
  before_action :set_payment, only: %i[ show edit update destroy ]

  # controlador de los pagos que se realizan
  def index
    @payments = Payment.all
  end

  def show
  end

  def new
    @title_modal = "Registrar pago"
    @sale_id = params[:sale_id]
    @sale = Sale.find( params[:sale_id] )
    @date_last_payment = @sale.payments.actives.no_first_pay.order(:date).first&.date
    @date_first_fee_no_pay = @sale.fees.no_payed.actives.first&.due_date
    @fee = Fee.current_fee( @sale_id ) #obtengo la cuota que corresponde pagar
    @total_to_pay = @fee.get_deuda # total valor de cuotas hasta hoy - monto pagado
    @apply_arrear = @fee.apply_arrear?
    @payments_currencies = PaymentsCurrency.actives
    if @apply_arrear
      if @fee.sale.has_expires_fees?
        @fecha_primer_cuota_impaga = @fee.sale.fecha_inicio_interes
        # Esto es el valor calculado del interes diario
        @interes_diario = @fee.interes_diario
      else
        # el pago esta al dia
        @fecha_primer_cuota_impaga = Date.today
        @interes_diario = 0
      end
      # El % que se seteo cuando se hizo la venta
      @porcentaje_interes = @fee.sale.arrear
      @interes_sugerido = @fee.calcular_interes
      @total_a_pagar = ( @interes_sugerido + @total_to_pay ).round(2)
    else
      @fecha_primer_cuota_impaga = Date.today
      @porcentaje_interes = 0
      @total_a_pagar = ( @total_to_pay ).round(2)
      @interes_diario = 0
    end
    @payment = Payment.new
  end

  def edit
  end

  def create
    payment = Payment.new(payment_params)
    ActiveRecord::Base.transaction do 
      # payment es lo que se pago, ese valor viene en calculo_en_pesos
      sale = Sale.find(params[:payment][:sale_id])
      fee = Fee.current_fee( sale.id, params[:payment][:date].to_time )
      payment.save
      if params[:interest].to_f > 0 # chequeamos si se le sumo intereses
        # discrimino el interes aplicado en la cuota
        interest = fee.interests.create(value: params[:interest].to_f, date: params[:payment][:date], comment: 'Mora por pago fuera de termino.', payment: payment)
      end
      if params[:adjust].to_f > 0 # Si agregaron algo al ajuste 
        adjust = fee.adjusts.create(value:  params[:adjust].to_f, comment:  params[:comment_adjust], date: params[:payment][:date], payment: payment)
      end
    end # transaction

    # aplicamos el pago a las cuotas
    payment.apply_payment_to_fees
    render json: { status: 'success', msg: 'Pago registrado' }, status: 200

    rescue => e
      @response = e.message.split(':')
      puts @response
      render json: { status: 'error', msg: 'Error del sistema' }, status: 402
  end

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

  private
    def set_payment
      @payment = Payment.find(params[:id])
    end

    def payment_params
      params.require(:payment).permit(:sale_id, :date, :payment, :payments_currency_id, :total, :taken_in, :active, :comment, images:[])
    end
end
