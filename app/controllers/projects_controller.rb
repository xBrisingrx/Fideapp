class ProjectsController < ApplicationController
  before_action :set_project, only: %i[ show edit update destroy ]

  def index
    @projects = Project.all
  end

  def show
    @title_modal = "Información del projecto"
    @status_color = 'lightblue'
  end

  def new
    @title_modal = "Nuevo proyecto"
    @project = Project.new
    @project_type = ProjectType.actives.order(:name)
    @materials = Material.actives.order(:name)
    @providers = Provider.actives.order(:name)
    @sectors = Sector.where(active: true)
    @urbanizations = Urbanization.actives.order(:name)
    @provider_roles = ProviderRole.where(active: true).order(:name)
    @payment_methods = PaymentMethod.where(active: true).order(:name)
  end

  def edit
  end

  def create  
    ActiveRecord::Base.transaction do 
      project = Project.new(project_params)
      if project.save
        render json: {status: 'success', msg: 'Proyecto registrado con exito'}, status: :ok
      end
    end
    rescue => e
      @response = e.message.split(':')
      puts @response
      render json: {status: 'error', msg: 'No se pudo registrar el proyecto'}, status: 402
  end

  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to project_url(@project), notice: "Project was successfully updated." }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def set_project
      @project = Project.find(params[:id])
    end

    def project_params
      params.require(:project).permit(:number, :name, :active, :price, :total, :status,:final_price,:subtotal,:description,:project_type_id, 
        :land_corner_price, :land_price, :price_fee, :price_fee_corner, :date, :number_of_payments, :finalized,
        project_providers_attributes: [:id, :provider_id,:provider_role_id,:payment_method_id,:price,:iva,:value_iva,:price_calculate,:porcent,:type_total],
        project_materials_attributes: [:id, :material_id,:type_units,:units,:price],
        apple_projects_attributes: [:id, :apple_id],
        land_projects_attributes: [:id, :land_id, :price])
    end
end
