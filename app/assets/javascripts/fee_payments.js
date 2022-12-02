let fee_payment_data = {
	payment: 0,
	tomado_en: 0,
	valor_en_pesos: 0,
	total_a_pagar: 0,
	pay_name: '',
	convertir_a_pesos() {
		if ( (this.payment > 0.0) && ( this.tomado_en > 0.0 )  && ( !isNaN(this.payment) ) && ( !isNaN(this.tomado_en) ) ) {
			this.valor_en_pesos = this.payment * this.tomado_en
			return this.valor_en_pesos
		}
		this.valor_en_pesos = 0.0
		return this.valor_en_pesos
	},
	reset() {
		this.payment = 0.0
		this.tomado_en = 0.0
		this.pay_name = ''
		this.valor_en_pesos = 0.0
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
	check_input( event, input, atributo ) {
		// ingresa monto pagado o en cuanto toma una moneda 
		// en caso de error seteo clase invalid
		let data = parseFloat(event.target.value)
		if (isNaN( data )) {
			data = 0.0
			addClassInvalid(input)
		} else {
			addClassValid(input)
		}

		if (atributo === 'payment') {
			this.payment = data
		} else {
			this.tomado_en = data
		}
		this.calc_valor_en_pesos('fee_payment')
	}
}