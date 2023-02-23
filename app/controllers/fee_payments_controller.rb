class FeePaymentsController < ApplicationController
  
  def new
    @title_modal = 'Ingresar pago'
    @currencies = Currency.where(active:true)
    @fee = Fee.find(params[:fee_id])
    @data = @fee.fee_payments.build
    @fee_payment = FeePayment.new
  end

  def create
    fee = Fee.find(params[:fee_id])
    fee_payments = fee.fee_payments.new(
      payment: params[:payment],
      pay_date: params[:pay_date],
      comment: params[:comment],
      payments_currency_id: params[:payments_currency_id],
      tomado_en: params[:tomado_en],
      total: params[:calculo_en_pesos],
      pay_name: params[:pay_name]
    )
    if !params[:images].nil?
      fee_payments.images = params[:images]
    end
    respond_to do |format|
      # create tiene un callback para actualizar fee
      if fee_payments.save!
        format.json { render json: {'status' => 'success', 'msg' => 'Pago registrado'}, location: @fee_payment }
      else
        format.json { render json: fee.fee_payments.errors, status: :unprocessable_entity }
      end
    end
    
    rescue => e
      puts "!!! rescue => #{e}"
      response = e.message.split(':')
      puts "===> #{response[1]}"
      response[1] = response[1].split(' ')[1..-1].join(' ')
      render json: { response[0] => response[1] }, status: 402
  end
end
