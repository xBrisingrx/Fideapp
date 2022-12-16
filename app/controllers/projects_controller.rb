class ProjectsController < ApplicationController
  before_action :set_project, only: %i[ show edit update destroy ]

  def index
    @projects = Project.all
  end

  def show
  end

  def new
    @title_modal = "Nuevo proyecto"
    @project = Project.new
    @project_type = ProjectType.actives
    @materials = Material.actives
    @providers = Provider.actives
    @sectors = Sector.where(active: true)
    @urbanizations = Urbanization.actives
    @provider_roles = ProviderRole.where(active: true)
    @payment_methods = PaymentMethod.where(active: true)
  end

  def edit
  end

  def create
    ActiveRecord::Base.transaction do 
      @project = Project.create(
        number: params[:number].to_i,
        name: params[:name],
        project_type_id: params[:project_type_id].to_i,
        description: params[:description],
        price: params[:price].to_f,
        final_price: params[:final_price].to_f,
        subtotal: params[:subtotal].to_f,
        status: :proceso,
        land_price: params[:land_price],
        land_corner_price: params[:land_corner_price]
      )

      if params[:cant_materials].to_i > 0
        materials = params[:cant_materials].to_i - 1
        for i in 0..materials do 
          @project.project_materials.create!(
            material_id: params["material_id_#{i}".to_sym].to_i,
            type_units: params["material_type_unit_#{i}".to_sym].to_i,
            units: params["material_units_#{i}".to_sym].to_i,
            price: params["material_price__#{i}".to_sym].to_i,
          )
        end
      end

      if params[:cant_providers].to_i > 0
        providers = params[:cant_providers].to_i - 1
        for i in 0..providers do 
          @coso = @project.project_providers.new(
            provider_id: params["provider_id_#{i}".to_sym].to_i,
            provider_role_id: params["provider_role_id_#{i}".to_sym].to_i,
            payment_method_id: params["payment_method_id_#{i}".to_sym].to_i,
            price: params["provider_price_#{i}".to_sym].to_f,
            iva: params["provider_iva_#{i}".to_sym].to_i,
            value_iva: params["provider_iva_#{i}".to_sym].to_f,
            price_calculate: params["provider_price_calculate_#{i}".to_sym].to_f,
            porcent: params["provider_porcent_#{i}".to_sym].to_f,
            porcent: params["type_total_#{i}".to_sym].to_i
          )
          puts @coso
          if !@coso.save!
            puts @coso.errors.messages
          end
        end
      end
      # raise 'cantidades'
      apple = Apple.find(params[:apple_id])
      AppleProject.create(apple_id: apple.id, project_id: @project.id)
      
      apple.lands.each do |land|
        if land.is_corner
          LandProject.create( land_id: land.id, project_id: @project.id, status: :pending, price: @project.land_corner_price )
        else
          LandProject.create( land_id: land.id, project_id: @project.id, status: :pending, price: @project.land_price )
        end
      end
      render json: {status: 'success', msg: 'Proyecto registrado con exito'}, status: :ok
    end # transaction

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
      params.require(:project).permit(:number, :name, :active, :price, :total, :status)
    end
end
