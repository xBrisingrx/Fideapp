class FeesController < ApplicationController
	
	def index
		# Obtengo las cuotas de una venta
		@fees = Fee.where(sale_id: params[:sale_id]).where('number != 0')
		@status = { 'pendiente' => 'Pendiente', 'pagado' => 'Pagada', 
        'pago_parcial' => 'Pago parcial', 'refinancied' => 'Refinanciado'}
	end

  def new
    @title_modal = "Agregar cuotas"
    sale = Sale.find(params[:sale_id])
    last_fee = sale.fees.order(number: 'ASC').no_cero.last
    due_date = (last_fee.blank?) ? Date.today.strftime('%d-%m-%y') : last_fee.due_date += 1.month
    @fee = Fee.new(sale: sale, due_date: due_date)
  end

  def create
    fee = Fee.new(fee_params) 
    sale = fee.sale
    last_fee = sale.fees.order(number: 'ASC').last
    fee.number = (last_fee.blank?) ? 1 : last_fee.number + 1 #excenario donde no hayan agregado cuotas
    fee.number_of_fees_to_add.to_i -= 1
    if fee.save
      render json: { status: 'success', msg: 'Cuotas agregadas' }, status: :created
    else
      render json: { status: 'error', msg: 'No se pudo agregar la cuota' }, status: :unprocessable_entity
    end
  end

	def show
    @cp = PaymentsCurrency.actives
    # obtengo info de una sola cuota
    @fee = Fee.find(params[:id])
    @title_modal = "Pagar cuota ##{@fee.number}"
    # Plata que quedo pendiente de cuotas anteriores 
    @adeuda = @fee.get_deuda
    # testeo que este vencida la cuota y que se haya seteado q se corresponda aplicar intereses
    if @fee.apply_arrear?
      # El % que se seteo cuando se hizo la venta
      @porcentaje_interes = @fee.sale.arrear
      # Esto es el valor calculado del interes diario
      # @interes_sugerido = calcular_interes!(@porcentaje_interes, @fee.fee_value, @fee.due_date)
      @interes_sugerido = @fee.calcular_interes
      @total_a_pagar = ( @interes_sugerido + @adeuda + @fee.value + @fee.get_adjusts ).round(2)
    else 
      @porcentaje_interes = 0
      @interes = 0.0
      @total_a_pagar = ( @adeuda + @fee.value + @fee.get_adjusts ).round(2)
    end
	end

  def update
    ActiveRecord::Base.transaction do 
      # payment es lo que se pago, ese valor viene en calculo_en_pesos
      # cuota.payment = params[:calculo_en_pesos].to_f
      fee = Fee.find(params[:id])
      # chequeamos si se le sumo intereses
      if params[:interest].to_f > 0
        # discrimino el interes aplicado en la cuota
        # cuota.interest = params[:interest].to_f
        fee.interests.create(value: params[:interest].to_f, date: params[:pay_date], comment: 'Mora por pago fuera de termino.')
      end

      if params[:adjust].to_f > 0 # Si agregaron algo al ajuste 
        fee.adjusts.create(value:  params[:adjust].to_f, comment:  params[:comment_adjust], date: params[:pay_date])
        # cuota.apply_adjust(params[:adjust].to_f, params[:comment_adjust]) # y las siguientes
      end

      sale = Sale.find(fee.sale.id)
      payment = sale.payments.new( 
              date: params[:pay_date], 
              payment: params[:payment], 
              taken_in: params[:value_in_pesos],
              comment: params[:name_pay],
              payments_currency_id: params[:payments_currency_id])
          if !params[:images].nil?
            payment.images = params[:images]
          end

      if payment.save
        render json: { status: 'success', msg: 'Pago registrado' }, status: 200
      else
        render json: { status: 'error', msg: 'No se pudo registrar el pago' }, status: 422
      end
    end # transaction
    rescue => e
      @response = e.message.split(':')
      puts @response
      render json: { status: 'error', msg: 'Error del sistema' }, status: 402
  end

  def update_old # Actualizar los valores de una cuota sigifica que se pago esa cuota
    cuota = Fee.find(params[:id])
    ActiveRecord::Base.transaction do 
      # payment es lo que se pago, ese valor viene en calculo_en_pesos
      # cuota.payment = params[:calculo_en_pesos].to_f

      # chequeamos si se le sumo intereses
      if params[:interest].to_f > 0
        # discrimino el interes aplicado en la cuota
        cuota.interest = params[:interest].to_f
        # cuota.interests.create(value:  params[:interest].to_f)
      end

      if params[:adjust].to_f > 0 # Si agregaron algo al ajuste 
        cuota.adjusts.create(value:  params[:adjust].to_f, comment:  params[:comment_adjust])
        # cuota.apply_adjust(params[:adjust].to_f, params[:comment_adjust]) # y las siguientes
      end

      # Calculo el total que se deberia haber pagado
      # Aca no sumo el valor de cuotas anteriores
      cuota.total_value = cuota.value + cuota.interest + cuota.get_adjusts 
      cuota.owes = cuota.total_value

      # Chequeo si se pago menos de lo que se debia, en caso de que haya sido asi pasa al atributo DEBE
      # if ( cuota.total_value >= cuota.payment )
      #   cuota.owes = (cuota.total_value - cuota.payment).round(2)
      # else
      #   cuota.owes = 0.0
      # end

      cuota.pay_date = params[:pay_date]
      cuota.payed = true
      cuota.comment = params[:comment]

      # si debe plata el status es pago parcial , sino pago total
      cuota.pay_status = ( cuota.owes > 0 ) ? :pago_parcial : :pagado

      # si el valor de la cuota cambia tenemos que actualizar el valor de la venta del lote
      recalcular_valor_venta = cuota.total_value_changed?
      if cuota.save!
        cuota.sale.calculate_total_value! if recalcular_valor_venta
        # este es el primer pago de esta cuota
        pago_de_cuota = cuota.fee_payments.new( 
            date: cuota.pay_date, 
            payment: params[:payment], 
            tomado_en: params[:value_in_pesos],
            total: params[:calculo_en_pesos],
            detail: params[:name_pay],
            payments_currency_id: params[:payments_currency_id],
            comment: params[:comment])
        if !params[:images].nil?
          pago_de_cuota.images = params[:images]
        end

        if pago_de_cuota.save!
          pago_de_cuota.update(code: pago_de_cuota.id) 
          cuota.aplicar_pago( params[:calculo_en_pesos].to_f, cuota.pay_date, pago_de_cuota.code )
          render json: { status: 'success', msg: 'Pago registrado' }, status: 200
        else
          render json: { status: 'error', msg: 'No se pudo registrar el pago' }, status: 422
        end
      else
        render json: { status: 'error', msg: 'No se pudo registrar el pago' }, status: 422
      end
    end # end transaction
    rescue => e
      @response = e.message.split(':')
      render json: { status: 'error', msg: 'No se pudo registrar el pago' }, status: 402
  end

  def details
    @cuota = Fee.find(params[:id])
    if @cuota.is_last_fee?
      @payments = Payment.payments_last_fee( @cuota.sale_id,@cuota.due_date )
    else
      @payments = Payment.by_month( @cuota.sale_id,@cuota.due_date )
    end
    @title_modal = 'Detalle del pago realizado'
  end

  private
  def fee_params
    params.require(:fee).permit(:sale_id, :value, :due_date, :number, :number_of_fees_to_add)
  end
end
