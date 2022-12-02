class ProviderRolesController < ApplicationController
  before_action :set_provider_rol, only: %i[ show edit update destroy ]

  # GET /provider_rols or /provider_rols.json
  def index
    @provider_roles = ProviderRole.all
  end

  # GET /provider_rols/1 or /provider_rols/1.json
  def show
  end

  # GET /provider_rols/new
  def new
    @provider_role = ProviderRole.new
  end

  # GET /provider_rols/1/edit
  def edit
  end

  # POST /provider_rols or /provider_rols.json
  def create
    @provider_role = ProviderRole.new(provider_role_params)

    respond_to do |format|
      if @provider_role.save
        format.html { redirect_to provider_role_url(@provider_role), notice: "Provider rol was successfully created." }
        format.json { render :show, status: :created, location: @provider_role }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @provider_role.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /provider_rols/1 or /provider_rols/1.json
  def update
    respond_to do |format|
      if @provider_role.update(provider_role_params)
        format.html { redirect_to provider_role_url(@provider_role), notice: "Provider rol was successfully updated." }
        format.json { render :show, status: :ok, location: @provider_role }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @provider_role.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /provider_rols/1 or /provider_rols/1.json
  def destroy
    @provider_role.destroy

    respond_to do |format|
      format.html { redirect_to provider_rols_url, notice: "Provider rol was successfully destroyed." }
      format.json { head :no_content }
    end
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
