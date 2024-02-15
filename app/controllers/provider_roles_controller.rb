class ProviderRolesController < ApplicationController
  before_action :set_provider_rol, only: %i[ show edit update destroy ]

  # GET /provider_rols or /provider_rols.json
  def index
    @provider_roles = ProviderRole.actives
  end

  # GET /provider_rols/1 or /provider_rols/1.json
  def show
  end

  # GET /provider_rols/new
  def new
    @title = "Agregar funcion de proveedor"
    @provider_role = ProviderRole.new
  end

  # GET /provider_rols/1/edit
  def edit
    @title = "Editar funcion de proveedor"
  end

  # POST /provider_rols or /provider_rols.json
  def create
    @provider_role = ProviderRole.new(provider_role_params)

    respond_to do |format|
      if @provider_role.save
        format.json { render json: { status: 'success', msg: 'Funcion de proveedor agregada' }, status: :created }
      else
        format.json { render json: @provider_role.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /provider_rols/1 or /provider_rols/1.json
  def update
    respond_to do |format|
      if @provider_role.update(provider_role_params)
        format.json { render json: { status: 'success', msg: 'Datos actualizados' }, status: :ok, location: @provider_role }
      else
        format.json { render json: @provider_role.errors, status: :unprocessable_entity }
      end
    end
  end

  def disable
    @provider_role = ProviderRole.find(params[:provider_role_id])
    if @provider_role.update!(active: false)
      render json: { status: 'success', msg: 'Funcion de proveedor eliminada' }, status: :ok
    else
      render json: { status: 'error', msg: 'Ocurrio un error al realizar la operación' }, status: :unprocessable_entity
    end

    rescue => e
      @response = e.message.split(':')
      render json: { @response[0] => @response[1] }, status: 402
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_provider_rol
      @provider_role = ProviderRole.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def provider_role_params
      params.require(:provider_role).permit(:name, :description, :active)
    end
end
