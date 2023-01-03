class PaymentsTypesController < ApplicationController
	before_action :set_material, only: %i[ show edit update destroy ]

  def index
    @payments_types = PaymentType.actives
  end

  def new
    @payment_type = PaymentType.new
  end

  def edit
  end

  def create
    @payment_type = PaymentType.new(payment_type_params)

    respond_to do |format|
      if @payment_type.save
        format.json { render json: { status: 'success', msg: 'Material registrado' }, status: :created }
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
    @payment_type = PaymentType.find(params[:material_id])
    if @payment_type.update(active:false)
      render json: { status: 'success', msg: 'Proveedor eliminado' }, status: :ok
    else
      render json: { status: 'error', msg: 'Ocurrio un error al realizar la operación' }, status: :unprocessable_entity
    end

    rescue => e
      @response = e.message.split(':')
      render json: { @response[0] => @response[1] }, status: 402
  end

  private
    def set_material
      @payment_type = PaymentType.find(params[:id])
    end

    def payment_type_params
      params.require(:material).permit(:name, :description)
    end
end