class LandsController < ApplicationController
  before_action :set_land, only: %i[ show edit update detail_sales]
  before_action :set_apple, only: %i[ index new edit ]
  before_action :set_name_enums, only: %i[ index new edit ]

  def index
    @lands = Land.where(apple_id: params[:apple_id], active: true)
    @apple_id = params[:apple_id]
  end

  def new
    @title_modal = 'Nuevo lote'
    @land = @apple.lands.build
  end

  def edit
    @title_modal = 'Editar lote'
  end

  def create
    @land = Land.new(land_params)

    respond_to do |format|
      if @land.save
        format.json { render json: {status: 'success', msg: 'Lote registrado'} , status: :created }
      else
        format.json { render json: @land.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @land.update(land_params)
        format.json { render json: {status: 'success', msg: 'Lote actualizado'} , status: :ok }
      else
        format.json { render json: @land.errors, status: :unprocessable_entity }
      end
    end
  end

  def disable
    pp params
    @land = Land.find(params[:land_id])
    if @land.available? || @land.canceled?
      if @land.update(active:false)
        render json: { status: 'success', msg: 'Lote eliminado' }, status: :ok
      else
        render json: { status: 'error', msg: 'Ocurrio un error al realizar la operación' }, status: :unprocessable_entity
      end
    end

    rescue => e
        @response = e.message.split(':')
        render json: { @response[0] => @response[1] }, status: 402
  end

  def detail_sales
    @sales = @land.sales
    @land_sale = @land.sale_products.where( product_type: :Land).first
    @status = { 'pendiente' => 'Pendiente', 'pagado' => 'Pagada', 'pago_parcial' => 'Pago parcial', 'refinancied' => 'Refinanciada'}
  end

  private
    def set_land
      @land = Land.find(params[:id])
    end

    def set_apple
      @apple = Apple.find(params[:apple_id])
    end

    def land_params
      params.require(:land).permit(:code, :is_corner, :is_green_space, :land_type, :measure, 
        :price, :space_not_available, :status, :area, :ubication, :apple_id, :blueprint)
    end

    # Paso a :es mis enumarados
    def set_name_enums
      @status = { 'available' => 'Disponible', 'bought' => 'Comprado', 'canceled' => 'Cancelado'}
      @land_type = { 'habitable' => 'Habitable', 'no_habitable' => 'No habitable', 'green_space' => 'Espacio verde' }
    end
end
