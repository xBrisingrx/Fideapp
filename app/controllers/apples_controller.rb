class ApplesController < ApplicationController
  before_action :set_apple, only: %i[ show edit update destroy ]

  def index
    @apples = Apple.actives.includes(:sector).includes(:urbanization)
  end

  def show
  end

  def filter_for_sector
    @apples = Apple.where( sector_id: params[:sector_id] ).where( active: true )
  end

  def new
    @title_modal = "Agregar manzana"
    @sectors = Sector.where(active: true)
    @condominia = Condominium.where(active: true)
    @apple = Apple.new
  end

  def edit
    @title_modal = "Editar manzana"
    @sectors = Sector.where(active: :true)
    @condominia = Condominium.where(active: true)
  end

  def create
    @apple = Apple.new(apple_params)

    respond_to do |format|
      if @apple.save
        format.json { render json: { status: 'success', msg: 'Manzana registrada' }, status: :created }
      else
        format.json { render json: @apple.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @apple.update(apple_params)
        format.json { render json: { status: 'success', msg: 'Datos actualizados' }, status: :ok, location: @apple }
      else
        format.json { render json: @apple.errors, status: :unprocessable_entity }
      end
    end
  end

  def disable
    @apple = Apple.find(params[:apple][:id])
    if @apple.update!(active: false)
      render json: { status: 'success', msg: 'Manzana eliminada' }, status: :ok
    else
      render json: { status: 'error', msg: 'Ocurrio un error al realizar la operación' }, status: :unprocessable_entity
    end

    rescue => e
      @response = e.message.split(':')
      render json: { @response[0] => @response[1] }, status: 402
  end

  private
    def set_apple
      @apple = Apple.find(params[:id])
    end

    def apple_params
      params.require(:apple).permit(:code, :hectares, :value, :space_not_available, :condominium_id, :sector_id, :active, :blueprint)
    end
end
