class SectorsController < ApplicationController
  before_action :set_sector, only: %i[ show edit update destroy ]

  def index
    @sectors = Sector.actives.includes(:urbanization)
  end

  def show; end

  def new
    @sector = Sector.new
    @urbanizations = Urbanization.actives
    @title_modal = "Registrar sector"
  end

  def edit
    @urbanizations = Urbanization.actives
    @title_modal = "Editar sector: #{@sector.name}"
  end

  def create
    @sector = Sector.new(sector_params)

    respond_to do |format|
      if @sector.save
        format.json { render json: { status: 'success', msg: 'Nuevo sector registrado' } , status: :created }
      else
        format.json { render json: @sector.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @sector.update(sector_params)
        format.json { render json: { status: 'success', msg: 'Datos del sector modificados' } , status: :ok }
      else
        format.json { render json: @sector.errors, status: :unprocessable_entity }
      end
    end
  end

  def disable
    @sector = Sector.find(params[:sector_id])
    if @sector.update(active:false)
      render json: { status: 'success', msg: 'Sector eliminado' }, status: :ok
    else
      render json: { status: 'error', msg: 'Ocurrio un error al realizar la operación' }, status: :unprocessable_entity
    end

    rescue => e
      @response = e.message.split(':')
      render json: { @response[0] => @response[1] }, status: 402
  end

  private
    def set_sector
      @sector = Sector.find(params[:id])
    end

    def sector_params
      params.require(:sector).permit(:name, :active, :size, :urbanization_id)
    end
end
