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
    @sale = Sale.find( params[:sale_id] )
    @date_last_payment = @sale.date_last_payment
    @date_first_fee_no_payed = @sale.date_first_fee_no_payed
    @fee = Fee.current_fee( @sale.id ) #obtengo la cuota que corresponde pagar
    @total_to_pay = @fee.get_deuda # total valor de cuotas hasta hoy - monto pagado
    @has_expires_fees = @sale.has_expires_fees?
    @payments_currencies = PaymentsCurrency.actives
    @payment = Payment.new
  end

  def edit
  end

  def create
    payment = Payment.new(payment_params)
    if payment.save
      render json: { status: 'success', msg: 'Pago registrado' }, status: 200
    else
      render json: { status: 'error', msg: payment.errors.messages }, status: :unprocessable_entity
    end
    rescue => e
      @response = e.message.split(':')
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
      params.require(:payment).permit(:sale_id, :date, :payment, :payments_currency_id, :total, :taken_in, :active, :comment, 
        :interest, :porcent_interest, :adjust,:comment_adjust, images:[])
    end
end
