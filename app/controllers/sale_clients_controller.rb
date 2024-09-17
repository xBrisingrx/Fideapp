class SaleClientsController < ApplicationController
  before_action :set_sale, only: %i[ show ]

  def index
  end

  def show;end

  def new
    @title_modal = "Agregar comprador/a al lote"
    @sale_client = SaleClient.new
    @clients = Client.actives
  end

  def create
    @sale_client = SaleClient.new(sale_params)
    @sale_client.sale_id = params[:sale_id]
    respond_to do |format|
      if @sale_client.save
        format.json { render json: {status: 'success', msg: 'Comprador agregado'} , status: :created }
      else
        format.json { render json: @sale_client.errors, status: :unprocessable_entity }
      end
    end
  end


  private
    def set_sale_client
      @sale_client = SaleClient.find(params[:id])
    end

    def sale_params
      params.require(:sale_client).permit(:client_id, :sale_id, :active)
    end
end