class MaterialsController < ApplicationController
  before_action :set_material, only: %i[ show edit update destroy ]

  def index
    @materials = Material.actives
  end

  def new
    @material = Material.new
  end

  def edit
  end

  def create
    @material = Material.new(material_params)

    respond_to do |format|
      if @material.save
        format.json { render json: { status: 'success', msg: 'Material registrado' }, status: :created }
      else
        format.json { render json: @material.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @material.update(material_params)
        format.json { render json: { status: 'success', msg: 'Datos actualizados' }, status: :ok }
      else
        format.json { render json: @material.errors, status: :unprocessable_entity }
      end
    end
  end

  def disable
    @material = Material.find(params[:material_id])
    if @material.update(active:false)
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
      @material = Material.find(params[:id])
    end

    def material_params
      params.require(:material).permit(:name, :description, :active)
    end
end
