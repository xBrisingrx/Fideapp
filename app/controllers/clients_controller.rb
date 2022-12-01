class ClientsController < ApplicationController
  before_action :set_client, only: %i[ show edit update destroy ]
  before_action :marital_status, only: %i[new edit]

  def index
    @clients = Client.actives
  end

  def show;end

  def new
    @title_modal = 'Nuevo cliente'
    @client = Client.new
  end

  def edit
    @title_modal = 'Editar cliente'
  end

  def create
    @client = Client.new(client_params)

    respond_to do |format|
      if @client.save
        format.json { render json: {status: 'success', msg: 'Nuevo cliente registrado'} , status: :created }
      else
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @client.update(client_params)
        format.json { render json: {status: 'success', msg: 'Datos del cliente actualizados'}, status: :ok }
      else
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  def disable
    @client = Client.find(params[:client_id])
    if @client.update(active:false)
      render json: { status: 'success', msg: 'Cliente eliminado' }, status: :ok
    else
      render json: { status: 'error', msg: 'Ocurrio un error al realizar la operación' }, status: :unprocessable_entity
    end

    rescue => e
      @response = e.message.split(':')
      render json: { @response[0] => @response[1] }, status: 402
  end

  private

    def set_client
      @client = Client.find(params[:id])
    end

    def client_params
      params.require(:client).permit(:code, :name, :last_name, :dni, :email, :direction, :marital_status, :phone, :active)
    end

    def marital_status
      @marital_status = ['Soltero', 'Casado', 'Divorciado', 'Viudo']
    end
end
