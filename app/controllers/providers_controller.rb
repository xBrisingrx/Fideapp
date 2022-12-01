class ProvidersController < ApplicationController
  before_action :set_provider, only: %i[ show edit update destroy ]

  def index
    @providers = Provider.actives
  end

  def show
  end

  def new
    @provider = Provider.new
  end

  def edit
  end

  def create
    @provider = Provider.new(provider_params)

    respond_to do |format|
      if @provider.save
        format.json { render json: { status: 'success', msg: 'Proveedor registrado' }, status: :created }
      else
        format.json { render json: @provider.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @provider.update(provider_params)
        format.json { render json: { status: 'success', msg: 'Datos actualizados' }, status: :ok }
      else
        format.json { render json: @provider.errors, status: :unprocessable_entity }
      end
    end
  end

  def disable
    @provider = Provider.find(params[:provider_id])
    if @provider.update(active:false)
      render json: { status: 'success', msg: 'Proveedor eliminado' }, status: :ok
    else
      render json: { status: 'error', msg: 'Ocurrio un error al realizar la operación' }, status: :unprocessable_entity
    end

    rescue => e
      @response = e.message.split(':')
      render json: { @response[0] => @response[1] }, status: 402
  end

  private
    def set_provider
      @provider = Provider.find(params[:id])
    end

    def provider_params
      params.require(:provider).permit(:name, :cuit, :description, :activity, :active)
    end
end
