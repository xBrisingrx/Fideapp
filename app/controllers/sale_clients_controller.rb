class SaleClientsController < ApplicationController
  before_action :set_sale, only: %i[ show ]

  def index
  end

  def show;end

  def new
    @sale_client = SaleClient.new
  end

  def create
    
  end


  private
    def set_sale_client
      @sale_client = SaleClient.find(params[:id])
    end

    def sale_params
      params.require(:sale_client).permit(:client_id, :sale_id, :active)
    end
end