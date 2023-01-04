class CurrenciesController < ApplicationController
	before_action :set_currency, only: %i[ show edit update destroy ]

  def index
    @currencies = Currency.actives
  end

  def new
    @currency = Currency.new
    @title_modal = 'Registro de divisa'
  end

  def edit
  	@title_modal = "Editando la divisa #{@currency.name}"
  end

  def create
    @currency = Currency.new(currency_params)

    respond_to do |format|
      if @currency.save
        format.json { render json: { status: 'success', msg: 'Divisa registrada' }, status: :created }
      else
        format.json { render json: @currency.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @currency.update(currency_params)
        format.json { render json: { status: 'success', msg: 'Datos actualizados' }, status: :ok }
      else
        format.json { render json: @currency.errors, status: :unprocessable_entity }
      end
    end
  end

  def disable
    @currency = Currency.find(params[:currency_id])
    if @currency.update(active:false)
      render json: { status: 'success', msg: 'Divisa eliminada' }, status: :ok
    else
      render json: { status: 'error', msg: 'Ocurrio un error al realizar la operación' }, status: :unprocessable_entity
    end

    rescue => e
      @response = e.message.split(':')
      render json: { @response[0] => @response[1] }, status: 402
  end

  private
    def set_currency
      @currency = Currency.find(params[:id])
    end

    def currency_params
      params.require(:currency).permit(:name, :detail, :active)
    end
end
