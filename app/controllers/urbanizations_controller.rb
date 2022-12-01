class UrbanizationsController < ApplicationController
  before_action :set_urbanization, only: %i[ show edit update destroy ]

  def index
    @urbanizations = Urbanization.where(active: true)
  end

  def new
    @title_modal = "Registrar urbanización"
    @urbanization = Urbanization.new
  end

  def edit
    @title_modal = "Editar urbanización"
  end

  def create
    @urbanization = Urbanization.new(urbanization_params)

    respond_to do |format|
      if @urbanization.save
        format.json { render json: { status: 'success', msg: 'Urbanización registrada' } , status: :created }
      else
        format.json { render json: @sector.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @urbanization.update(urbanization_params)
        format.json { render json: { status: 'success', msg: 'Datos actualizados' } , status: :ok }
      else
        format.json { render json: @sector.errors, status: :unprocessable_entity }
      end
    end
  end

  def disable
    pp params[:urbanization_id]
    @urbanization = Urbanization.find(params[:urbanization_id])
    if @urbanization.update(active:false)
      render json: { status: 'success', msg: 'Urbanización eliminada' }, status: :ok
    else
      render json: { status: 'error', msg: 'Ocurrio un error al realizar la operación' }, status: :unprocessable_entity
    end

    rescue => e
      @response = e.message.split(':')
      pp @response
      render json: { @response[0] => @response[1] }, status: 402
  end

  private
    def set_urbanization
      @urbanization = Urbanization.find(params[:id])
    end

    def urbanization_params
      params.require(:urbanization).permit(:name, :active, :size)
    end
end
