class FeePaymentsController < ApplicationController
  
  def new
    @cp = PaymentsCurrency.actives
    @fee = Fee.find(params[:fee_id])
    # Plata que quedo pendiente de cuotas anteriores 
    @adeuda = @fee.get_deuda + @fee.get_fee_owes
    @data = @fee.fee_payments.build
    @fee_payment = FeePayment.new
    @title_modal = "Ingresar pago de cuota ##{@fee.number}"
    # testeo que este vencida la cuota y que se haya seteado q se corresponda aplicar intereses
    # if @fee.apply_arrear?
    #   # El % que se seteo cuando se hizo la venta
    #   @porcentaje_interes = @fee.sale.arrear
    #   # Esto es el valor calculado del interes diario
    #   @interes_sugerido = @fee.calcular_interes
    #   @total_a_pagar =  @interes_sugerido + @adeuda
    # else 
    #   @porcentaje_interes = 0
    #   @interes = 0.0
    #   @total_a_pagar = @adeuda
    # end
    @porcentaje_interes = 0
    @interes = 0.0
    @total_a_pagar = @adeuda
  end

  def create
    fee = Fee.find(params[:fee_id])
    fee_payments = fee.fee_payments.new(
      payment: params[:payment],
      date: params[:date],
      comment: params[:comment],
      payments_currency_id: params[:payments_currency_id],
      tomado_en: params[:tomado_en],
      total: params[:calculo_en_pesos],
      detail: params[:name_pay],
      code: FeePayment.count + 1,
    )
    if !params[:images].nil?
      fee_payments.images = params[:images]
    end

    if params[:fee_payment_adjust].to_f > 0
      fee.adjusts.create(value:  params[:adjust].to_f, comment:  params[:comment_adjust])
    end
  
    respond_to do |format|
      # create tiene un callback para actualizar fee
      if fee_payments.save!
        fee.aplicar_pago( fee_payments.payment, fee.pay_date, fee_payments.code )
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

  def disable
    fee_payment = FeePayment.find(params[:fee_payment_id])
    if fee_payment.disable
      render json: { status: 'success', msg: 'Pago eliminado' }, status: :ok
    else
      render json: { status: 'error', msg: 'Ocurrio un error al realizar la operación' }, status: :unprocessable_entity
    end

    rescue => e
        @response = e.message.split(':')
        render json: { @response[0] => @response[1] }, status: 402
  end

  private 

  def fee_payment_params
    require(:fee_payment).permit(:fee_id, :date, :detail, :comment, :tomado_en, :total, :payment, :payments_currency_id)
  end
end
