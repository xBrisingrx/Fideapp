const payment_plan = {
	add(){
		if(document.getElementById("payment_plan_date").value === ""){
			noty_alert('info', 'Debe ingresar la fecha')
			return
		}
		const payment_plan_quantity_first_pay = parseInt(document.getElementById('payment_plan_quantity_first_pay').value)
		const payment_plan_quantity_quotes = parseInt(document.getElementById('payment_plan_quantity_quotes').value)
		let payment_plan_date = new Date(`${document.getElementById("payment_plan_date").value}T00:00:00`)

		if( !valid_number(payment_plan_quantity_first_pay) && !valid_number(payment_plan_quantity_quotes) ) {
			noty_alert('info', 'Debe ingresar la cantidad de pagos')
			return
		}
		const quantity_payment_plan = document.getElementsByClassName('payment-plan').length + 1
		let html_to_insert = `<table class="table table-responsive payment-plan">
		<thead>
			<th>Opcion #${quantity_payment_plan}</th>`
		if (payment_plan_quantity_first_pay > 0) {
			for (let index = 1; index <= payment_plan_quantity_first_pay; index++) {
				html_to_insert += `<th>${meses[payment_plan_date.getMonth()]}-${payment_plan_date.getFullYear()}</th>`
				payment_plan_date.setMonth( payment_plan_date.getMonth() + 1 )
			}
			html_to_insert += `<th></th>`
		}

		if (payment_plan_quantity_quotes > 0) {
			for (let index = 1; index <= payment_plan_quantity_quotes; index++) {
				html_to_insert += `<th>${meses[payment_plan_date.getMonth()]}-${payment_plan_date.getFullYear()}</th>`
				payment_plan_date.setMonth( payment_plan_date.getMonth() + 1 )
			}
		}
		html_to_insert += `</thead>
			<tbody>
				<tr>
					<td>TOTAL $</td>
		`
		if (payment_plan_quantity_first_pay > 0) {
			for (let index = 1; index <= payment_plan_quantity_first_pay; index++) {
				html_to_insert += `<td>
					Entrega ${index}
				</td>`
			}
			html_to_insert += `<td>SALDO</td>`
		}
		if (payment_plan_quantity_quotes > 0) {
			for (let index = 1; index <= payment_plan_quantity_quotes; index++) {
				html_to_insert += `<td>
					Cuota ${index}
				</td>`
			}
		}
		html_to_insert += `
			<tr>
				<td><input class='form-control' type='text' id='total-option' disabled/></td>
		`
		// lo reseteo para tomar la fecha en los inputs
		payment_plan_date = new Date(`${document.getElementById("payment_plan_date").value}T00:00:00`)
		payment_plan_date.setDate(10)
		
		if (payment_plan_quantity_first_pay > 0) {
			for (let index = 1; index <= payment_plan_quantity_first_pay; index++) {
				html_to_insert += `<td><input type='text' data-type='currency' class='payment-plan-first-pay-value form-control payment-plan-value' 
					data-date='${payment_plan_date.toLocaleDateString('es-AR')}' 
					data-option=${quantity_payment_plan}
					data-number=${index}
					onchange='payment_plan.sum_payment_plan(event)'/></td>`
				payment_plan_date.setMonth( payment_plan_date.getMonth() + 1)
			}
			html_to_insert += `<td><input class='form-control' type='text' id='first-pay-saldo' disabled/></td>`
		}
		if (payment_plan_quantity_quotes > 0) {
			for (let index = 1; index <= payment_plan_quantity_quotes; index++) {
				html_to_insert += `<td><input type='text' data-type='currency' class='payment-plan-quote-value form-control payment-plan-value' 
					data-date='${payment_plan_date.toLocaleDateString('es-AR')}' 
					data-option=${quantity_payment_plan} 
					data-number=${index} 
					onchange='payment_plan.sum_payment_plan(event)'/></td>`
				payment_plan_date.setMonth( payment_plan_date.getMonth() + 1)
			}
		}
		document.getElementsByClassName('payment_plan_data')[0].innerHTML += html_to_insert
		document.getElementById('payment_plan_quantity_first_pay').value = ''
		document.getElementById('payment_plan_quantity_quotes').value = ''

		$("input[data-type='currency']").on({
			keyup: function() {
				formatCurrency($(this));
			},
			blur: function() { 
				formatCurrency($(this), "blur");
			}
		})
	},
	sum_payment_plan(event){
		let sum_total = 0
		let sum_first_pay = 0
		const table = event.target.parentElement.parentElement.parentElement.parentElement
		if ( table.querySelectorAll('.payment-plan-first-pay-value').length > 0 ) {
			const first_pay_inputs = table.querySelectorAll('.payment-plan-first-pay-value')
			sum_first_pay = Array.from(first_pay_inputs).reduce( (acum, element) => acum + string_to_float_with_value(element.value), 0 )
		}

		if ( table.querySelectorAll('.payment-plan-quote-value').length > 0 ) {
			const payment_plan_quote_pay_inputs = table.querySelectorAll('.payment-plan-quote-value')
			sum_total = Array.from(payment_plan_quote_pay_inputs).reduce( (acum, element) => acum + string_to_float_with_value(element.value), sum_first_pay )
		}

		if (sum_first_pay > 0) {
			table.querySelector('#first-pay-saldo').value = numberFormat.format(sum_total - sum_first_pay) 
		}
		table.querySelector('#total-option').value = numberFormat.format(sum_total)
	},
  add_to_form(form, entity){
		// entity es el nombre con el que vamos a enviar nuestros valores
		// este metodo lo uso en projectos y en el selector de plan de pagos.
		const tables = document.getElementsByClassName("payment-plan")
		let payment_plans_index = 0
		for (let table_index = 0; table_index < tables.length; table_index++) {
			const table = tables[table_index]
			const quotes = table.querySelectorAll('.payment-plan-value')
			let cantidad_cuotas = 1
			for(let i = 0; i < quotes.length; i++) {
				const element = quotes[i];
				const plan_category = ( element.classList.contains('payment-plan-first-pay-value') ) ? 1 : 2
				form.append( `${entity}[${payment_plans_index}][number]` , cantidad_cuotas)	
				form.append( `${entity}[${payment_plans_index}][category]`,plan_category)	
				form.append( `${entity}[${payment_plans_index}][date]` , element.dataset.date)
				form.append( `${entity}[${payment_plans_index}][price]` ,  string_to_float_with_value(element.value))
				form.append( `${entity}[${payment_plans_index}][option]` , element.dataset.option)
				payment_plans_index++
				cantidad_cuotas++
			}
		}
	},
	valid_form_data(){
		const quotes = document.querySelectorAll('.payment-plan-value')
		let response = true
		if( !document.getElementById('project_finalized').checked && quotes.length == 0 ) {
			noty_alert('info', 'No se agrego plan de pagos.')
			return false 
		} else {
			for(let i = 0; i < quotes.length; i++) {
				const element = quotes[i]
				if( valid_number(string_to_float_with_value(element.value)) ){
					addClassValid(element)
				} else {
					addClassInvalid(element)
					response = false
				}
			}
	
			return response
		}
	},
	set_payment_plan_date(){
		document.getElementById('payment_plan_date').value = document.getElementById('project_date').value
	},
}