class PaymentsTypesController < ApplicationController
	before_action :set_payment_type, only: %i[ show edit update destroy ]

  def index
    @payments_types = PaymentsType.actives
  end

  def new
    @payment_type = PaymentsType.new
    @title_modal = 'Registrar medio de pago'
  end

  def show
    render json: @payment_type.currencies
  end

  def edit
  end

  def create
    @payment_type = PaymentsType.new(payment_type_params)

    respond_to do |format|
      if @payment_type.save
        format.json { render json: { status: 'success', msg: 'Medio de pago registrado' }, status: :created }
      else
        format.json { render json: @payment_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @payment_type.update(payment_type_params)
        format.json { render json: { status: 'success', msg: 'Datos actualizados' }, status: :ok }
      else
        format.json { render json: @payment_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def disable
    @payment_type = PaymentsType.find(params[:material_id])
    if @payment_type.update(active:false)
      render json: { status: 'success', msg: 'Medio de pago eliminado' }, status: :ok
    else
      render json: { status: 'error', msg: 'Ocurrio un error al realizar la operación' }, status: :unprocessable_entity
    end

    rescue => e
      @response = e.message.split(':')
      render json: { @response[0] => @response[1] }, status: 402
  end

  private
    def set_payment_type
      @payment_type = PaymentsType.find(params[:id])
    end

    def payment_type_params
      params.require(:payments_type).permit(:name, :description, :need_exchange)
    end
end