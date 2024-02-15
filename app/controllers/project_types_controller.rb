class ProjectTypesController < ApplicationController
  before_action :set_project_type, only: %i[ show edit update destroy ]

  def index
    @project_types = ProjectType.actives
  end

  def new
    @project_type = ProjectType.new
  end

  def edit
  end

  def create
    @project_type = ProjectType.new(project_type_params)

    respond_to do |format|
      if @project_type.save
        format.json { render json: { status: 'success', msg: 'Tipo de proyecto agregado' }, status: :created }
      else
        format.json { render json: @project_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @project_type.update(project_type_params)
        format.json { render json: { status: 'success', msg: 'Datos actualizados' }, status: :ok, location: @project_type }
      else
        format.json { render json: @project_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def disable
    @project_type = ProjectType.find(params[:project_type_id])
    if @project_type.update!(active: false)
      render json: { status: 'success', msg: 'Tipo de proyecto eliminado' }, status: :ok
    else
      render json: { status: 'error', msg: 'Ocurrio un error al realizar la operación' }, status: :unprocessable_entity
    end

    rescue => e
      @response = e.message.split(':')
      render json: { @response[0] => @response[1] }, status: 402
  end

  private
    def set_project_type
      @project_type = ProjectType.find(params[:id])
    end

    def project_type_params
      params.require(:project_type).permit(:name, :description, :active)
    end
end
