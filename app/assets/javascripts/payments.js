let payment = {
	valor_cuota: 0,
	recargo: 0,
	ajuste: 0,
	total_a_pagar: 0,
	adeuda: 0,
	payment: 0.0,
	tomado_en: 0.0,
	valor_en_pesos: 0.0,
	name_pay:'',
	form_data: '',
	id: '',
	date:'',
	total_to_pay(){
		return this.ajuste + this.adeuda + this.recargo
	},
	sumar_sin_recargo() {
		return this.ajuste + this.adeuda + this.valor_cuota
	},
	sumar_sin_ajuste() {
		return this.recargo + this.adeuda + this.valor_cuota
	},
	sumar_pago_parcial(){
		return this.total_a_pagar + this.ajuste
	},
	convertir_a_pesos() {
		if ( (this.payment > 0.0) && ( this.tomado_en > 0.0 )  && ( !isNaN(this.payment) ) && ( !isNaN(this.tomado_en) ) ) {
			return this.payment * this.tomado_en
		}
		return 0.0
	},
	reset() {
		this.payment = 0.0
		this.tomado_en = 0.0
		this.name_pay = ''
		this.valor_en_pesos = 0.0
		this.date = ''
	},
	calc_valor_en_pesos(name){
		let currency = document.getElementById('currency_id').value
		if (currency == 2 || currency == 3) {
			this.valor_en_pesos = this.convertir_a_pesos()
			document.getElementById(`${name}_calculo_en_pesos`).value = this.valor_en_pesos
		} else {
			let fee_payment_value = document.getElementById(`${name}_payment`).value
			document.getElementById(`${name}_value_in_pesos`).value = 1
			document.getElementById(`${name}_calculo_en_pesos`).value = ( !isNaN( fee_payment_value ) ) ? fee_payment_value : 0.0
		}
	},
	get_arrear(event){
		// obtenemos el valor de la mora acumulada por inflacion
		// en el input ingresarmos el % de inflacion acumulado
    this.recargo = (event.target.value * this.adeuda)/100
    document.querySelector('#payment_interest').value = string_to_currency(`${this.recargo}`)
    document.querySelector('#payment_total_to_pay').innerHTML = string_to_currency(`${this.total_to_pay()}`)
  },
	sum_interest(event){
		if(event.target.value == ''){
			this.recargo = 0
			event.target.value = 0
		} else {
			this.recargo = string_to_float_with_value(event.target.value)
		}
		document.querySelector('#payment_total_to_pay').innerHTML = string_to_currency(`${this.total_to_pay()}`)
	},
	update_adjust(event){
		const adjust = string_to_float_with_value(event.target.value)
		if (!isNaN( adjust )) {
			this.ajuste = adjust
			addClassValid(event.target)
		} else {
			this.ajuste = 0.0
		}
		document.querySelector('#payment_total_to_pay').innerHTML = string_to_currency(`${this.total_to_pay()}`)
	}
}