class UrbanizationsController < ApplicationController
  before_action :set_urbanization, only: %i[ show edit update destroy ]

  # GET /urbanizations or /urbanizations.json
  def index
    @urbanizations = Urbanization.where(active: true)
  end

  # GET /urbanizations/1 or /urbanizations/1.json
  def show;end

  # GET /urbanizations/new
  def new
    @title_modal = "Registrar urbanización"
    @urbanization = Urbanization.new
  end

  # GET /urbanizations/1/edit
  def edit
    @title_modal = "Editar urbanización"
  end

  # POST /urbanizations or /urbanizations.json
  def create
    @urbanization = Urbanization.new(urbanization_params)

    respond_to do |format|
      if @urbanization.save
        format.json { render json: { status: 'success', msg: 'Urbanizajción registrada' } , status: :created }
      else
        format.json { render json: @sector.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /urbanizations/1 or /urbanizations/1.json
  def update
    respond_to do |format|
      if @urbanization.update(urbanization_params)
        format.json { render json: { status: 'success', msg: 'Datos actualizados' } , status: :ok }
      else
        format.json { render json: @sector.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /urbanizations/1 or /urbanizations/1.json
  def destroy
    @urbanization.destroy
    respond_to do |format|
      format.html { redirect_to urbanizations_url, notice: "Urbanization was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def disable
    @urbanization = Urbanization.find(params[:urbanization][:id])
    if @urbanization.update(active:false)
      render json: { status: 'success', msg: 'Urbanización eliminada' }, status: :ok
    else
      render json: { status: 'error', msg: 'Ocurrio un error al realizar la operación' }, status: :unprocessable_entity
    end

    rescue => e
      @response = e.message.split(':')
      render json: { @response[0] => @response[1] }, status: 402
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_urbanization
      @urbanization = Urbanization.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def urbanization_params
      params.require(:urbanization).permit(:name, :active, :size)
    end
end
