class PaymentsCurrenciesController < ApplicationController
	before_action :set_material, only: %i[ show edit update destroy ]

  def index
    @payments_currencies = PaymentsCurrency.actives
  end

  def new
    @payment_currency = PaymentsCurrency.new
    @currencies = Currency.actives 
    @payment_type = PaymentsType.find(params[:payment_type_id])
    @title_modal = 'Agregar divisa al metodo de pago'
  end

  def edit
  end

  def create
    @payment_currency = PaymentsCurrency.new(payment_currency_params)

    respond_to do |format|
      if @payment_currency.save
        format.json { render json: { status: 'success', msg: 'Divisa agregada' }, status: :created }
      else
        format.json { render json: @payment_currency.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @payment_currency.update(payment_currency_params)
        format.json { render json: { status: 'success', msg: 'Datos actualizados' }, status: :ok }
      else
        format.json { render json: @payment_currency.errors, status: :unprocessable_entity }
      end
    end
  end

  def disable
    @payment_currency = PaymentsCurrency.find(params[:material_id])
    if @payment_currency.update(active:false)
      render json: { status: 'success', msg: 'Divisa eliminado' }, status: :ok
    else
      render json: { status: 'error', msg: 'Ocurrio un error al realizar la operación' }, status: :unprocessable_entity
    end

    rescue => e
      @response = e.message.split(':')
      render json: { @response[0] => @response[1] }, status: 402
  end

  private
    def set_material
      @payment_currency = PaymentsCurrency.find(params[:id])
    end

    def payment_currency_params
      params.require(:payments_currency).permit(:currency_id, :payments_type_id)
    end
end
