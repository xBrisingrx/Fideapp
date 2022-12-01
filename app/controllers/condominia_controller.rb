class CondominiaController < ApplicationController
  before_action :set_condominium, only: %i[ show edit update destroy ]

  def index
    @condominia = Condominium.actives
  end

  def new
    @condominium = Condominium.new
  end

  def edit
  end

  def create
    @condominium = Condominium.new(condominium_params)

    respond_to do |format|
      if @condominium.save
        format.json { render json: { status: 'success', msg: 'Condominio registrado' }, status: :created }
      else
        format.json { render json: @condominium.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @condominium.update(condominium_params)
        format.json { render json: { status: 'success', msg: 'Datos actualizados' }, status: :ok }
      else
        format.json { render json: @condominium.errors, status: :unprocessable_entity }
      end
    end
  end

  def disable
    @condominium = Condominium.find(params[:condominium_id])
    if @condominium.update(active:false)
      render json: { status: 'success', msg: 'Condominio eliminado' }, status: :ok
    else
      render json: { status: 'error', msg: 'Ocurrio un error al realizar la operación' }, status: :unprocessable_entity
    end

    rescue => e
      @response = e.message.split(':')
      render json: { @response[0] => @response[1] }, status: 402
  end

  private
    def set_condominium
      @condominium = Condominium.find(params[:id])
    end

    def condominium_params
      params.require(:condominium).permit(:name, :description, :active)
    end
end
