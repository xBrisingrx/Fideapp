class FeesController < ApplicationController
	
	def index
		# Obtengo las cuotas de una venta
		@fees = Fee.where(sale_id: params[:sale_id]).where('number != 0')
		@status = { 'pendiente' => 'Pendiente', 'pagado' => 'Pagada', 'pago_parcial' => 'Pago parcial'}
	end

	def show
		@currencies = Currency.select(:id, :name).where(active: true)
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
      @interes_sugerido = 0
      @total_a_pagar = @fee.value + @interes_sugerido + @adeuda
    else 
      @porcentaje_interes = 0
      @interes = 0.0
      @total_a_pagar = @fee.value + @adeuda
    end
	end

  def update # Actualizar los valores de una cuota sigifica que se pago esa cuota
    cuota = Fee.find(params[:id])
    ActiveRecord::Base.transaction do 
      # payment es lo que se pago, ese valor viene en calculo_en_pesos
      cuota.payment = params[:calculo_en_pesos].to_f

      # chequeamos si se le sumo intereses
      if params[:interest].to_f > 0
        # discrimino el interes aplicado en la cuota
        cuota.interest = params[:interest].to_f
      end

      if params[:adjust].to_f > 0 # Si agregaron algo al ajuste 
        cuota.apply_adjust(params[:adjust].to_f, params[:comment_adjust]) # y las siguientes
      end

      # Calculo el total que se deberia haber pagado
      # Aca no sumo el valor de cuotas anteriores
      cuota.total_value = cuota.value + cuota.interest + cuota.get_adjusts 

      # Chequeo si se pago menos de lo que se debia, en caso de que haya sido asi pasa al atributo DEBE
      if ( cuota.total_value >= cuota.payment )
        cuota.owes = (cuota.total_value - cuota.payment).round(2)
      else
        cuota.owes = 0.0
      end
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
            currency_id: params[:currency_id],
            comment: params[:comment] )
        if !params[:images].nil?
          pago_de_cuota.images = params[:images]
        end

        if pago_de_cuota.save!
          # Lo abonado es mayor a lo que se debe de la cuota
          cuota.pago_supera_cuota( cuota.payment - cuota.total_value, cuota.pay_date ) if ( cuota.total_value < cuota.payment )
          render json: { status: 'success', msg: 'Pago registrado' }, status: 200
        else
          render json: { status: 'error', msg: 'No se pudo registrar el pago' }, status: 422
        end
      else
        render json: { status: 'error', msg: 'No se pudo registrar el pago' }, status: 422
      end
      # raise 'lands fees/update'
    end # end transaction
    rescue => e
      @response = e.message.split(':')
      puts @response
      render json: { status: 'error', msg: 'No se pudo registrar el pago' }, status: 402
  end

  def details
    @cuota = Fee.find(params[:id])
    @title_modal = 'Detalle del pago realizado'
  end
end
