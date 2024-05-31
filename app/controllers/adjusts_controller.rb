class AdjustsController < ApplicationController
  def new
    @sale = Sale.find(params[:sale_id])
    @adjust = Adjust.new()
    @fees = Sale.find(params[:sale_id]).fees.actives.select(:id, :number)
    @title_modal = "Agregar ajuste"
  end

  def create
    adjust = Adjust.new(adjust_params)
    if adjust.save
      render json: { status: 'success', msg: 'Adjuste aplicado' }, status: :created
    else
      render json: { status: 'error', msg: 'No se pudo aplicar el ajuste' }, status: :unprocessable_entity
    end
  end

  private
  def adjust_params
    params.require(:adjust).permit(:sale_id, :value, :comment, :fee_id, :apply_to_many_fees)
  end
end
