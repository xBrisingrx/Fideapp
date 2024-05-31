let projects_table;
let project = {
	project_price: '',
	subtotal: 0,
	final_price: 0,
	lands: [],
	lands_corner: [],
	cant_lands:0,
	cant_corners:0,
	land_price:0,
	land_corner_price:0,
	form: new FormData(),
	add_number_input(nodo,delete_btn, disabled, className, input_id, placeholder = ''){
		let newNode = document.createElement("input");
		newNode.type = 'number'
		newNode.id = input_id
		newNode.disabled = disabled
		newNode.placeholder = placeholder
		newNode.className = `form-control form-control-sm rounded-0 ${className} col-md-2 ml-2 mr-2`
		
		nodo.insertBefore(newNode, delete_btn )

		if (input_id == 'porcent_input') {

			nodo.querySelector('#porcent_input').onchange = function(e){
				console.info('cambio de porcentaje')
			}
		}
	},
	remove_inputs(nodo) {
		if (nodo.querySelector(`#provider_price`) != null) {
			nodo.querySelector(`#provider_price`).remove()
		}
		if (nodo.querySelector('#list_providers_generate') != null) {
			nodo.querySelector('#list_providers_generate').remove()
		}
		if (nodo.querySelector('#porcent_input') != null) {
			nodo.querySelector('#list_providers_generate').remove()
		}
	},
	submit(event){
		event.preventDefault()
		event.stopPropagation()
		if( !this.valid_form() ){
			return
		}
		this.form.append('project[date]', document.getElementById('project_date').value )
		this.form.append('project[number]', document.getElementById('project_number').value )
		this.form.append('project[project_type_id]', parseInt(document.getElementById('project_project_type_id').value ) )
		this.form.append('project[name]', document.getElementById('project_name').value )
		this.form.append('project[price]', project.project_price )
		this.form.append('project[final_price]', parseFloat( this.final_price ) )
		this.form.append('project[subtotal]', parseFloat( this.subtotal ) )
		this.form.append('project[description]', document.getElementById('project_description').value )
		this.form.append('project[number_of_payments]', 0 )
		this.form.append('project[finalized]', document.getElementById('project_finalized').checked )
		this.form.append('project[land_price]', string_to_float('project_land_price') )
		this.form.append('project[land_corner_price]', string_to_float('project_land_corner_price') )
		
		
		project_providers.add_to_form()
		project_materials.add_to_form()
		project_apples.add_apples_to_form()
		project_apples.add_lands_to_form()
		if( !document.getElementById('project_finalized').checked ) {
			payment_plan.add_to_form(this.form,'project[payment_plans_attributes]')
		}
		fetch('/projects/', {
      method: 'POST',
      headers: {           
        'X-CSRF-Token': document.getElementsByName('csrf-token')[0].content,
      },
      body: this.form
    })
	  .then( response => response.json() )
	  .then( response => {
	  	if (response.status === 'success') {
	  		noty_alert(response.status, response.msg)
	  		window.location.replace("/projects");	
	  	}
	  } )
	  .catch( error => noty_alert('error', 'Ocurrio un error, no se pudo registrar el proyecto') )
	},
	valid_form(){

		if(document.getElementsByClassName("land").length == 0) {
			noty_alert('info','Debe seleccionar los lotes afectados al proyecto')
			return false
		}

		if( document.getElementById('project_date').value == '' ) {
			addClassInvalid( document.getElementById('project_date') )
			return false
		} else {
			addClassValid( document.getElementById('project_date') )
		}

		if( document.getElementById('project_number').value == '' ) {
			addClassInvalid( document.getElementById('project_number') )
			return false
		} else {
			addClassValid( document.getElementById('project_number') )
		}

		if( document.getElementById('project_project_type_id').value == '' ) {
			addClassInvalid( document.getElementById('project_project_type_id') )
			return false
		} else {
			addClassValid( document.getElementById('project_project_type_id') )
		}

		if( document.getElementById('project_name').value == '' ) {
			addClassInvalid( document.getElementById('project_name') )
			return false
		} else {
			addClassValid( document.getElementById('project_name') )
		}
		
		if( valid_number(this.subtotal) ) {
			addClassValid( document.getElementById('project_subtotal') )
		} else {
			addClassInvalid( document.getElementById('project_subtotal') )
			return false
		}

		if( valid_number(this.final_price) ) {
			addClassValid( document.getElementById('project_final_price') )
		} else {
			addClassInvalid( document.getElementById('project_final_price') )
			return false
		}

		if( valid_number(string_to_float('project_land_price')) ) {
			addClassValid( document.getElementById('project_land_price') )
		} else {
			addClassInvalid( document.getElementById('project_land_price') )
			return false
		}

		if( valid_number(string_to_float('project_land_corner_price')) ) {
			addClassValid( document.getElementById('project_land_corner_price') )
		} else {
			addClassInvalid( document.getElementById('project_land_corner_price') )
			return false
		}

		if(!payment_plan.valid_form_data()){
			return false
		}
		return true
	},
	disabled_and_reset_select(select_id, select_class){
		$(`#${select_id} option:selected`).attr('disabled', 'disabled')
		$(`.${select_class}`).val('').trigger('change')
	},
	validate_price(){
		this.project_price = parseFloat( document.querySelector('#form-project #project_price').value )
		if (isNaN(this.project_price)) {
			noty_alert('warning', 'El valor ingresado del proyecto no es valido')
			document.querySelector('#form-project #add-provider').disabled = true
			return false
		} else if (this.project_price <= 0 ) {
			noty_alert('warning', 'No se ha ingresado precio al proyecto')
			document.querySelector('#form-project #add-provider').disabled = true
			return false
		} else {
			document.querySelector('#form-project #add-provider').disabled = false
			this.calculate_subtotal()
			return true
		}
	},
	update_summary_table(){ // actualizamos la tabla RESUMEN
		if ($('#project_project_type_id option:selected').val() == '') {
			noty_alert('info', 'Por favor seleccione el tipo de proyecto')
			return
		}
		if (!valid_number(this.final_price)) {
			// hago una salvedad para cuando seleccionan el tipo de proyecto 
			// en tipo de proyecto tengo un onchange por si sucede que ingresan valor al proyecto pero no seleccionaron el tipo de proyecto
			return
		}
		// agregamos o en caso de ya haber sido agregada actualizamos el precio y % que representa el valor del proyecto
		let sumary_body = document.getElementById('summary-body')
		// agregamos o en caso de ya haber sido agregada actualizamos el precio y % que representa c/interviniente
		for (let i = 0; i < project_providers.list.length; i++){
			let provider = project_providers.list[i]
			if ( sumary_body.querySelector(`#summary_provider_id_${provider.provider_id}`) != null ) {
				const final_porcent = project_providers.represent_final_porcent(provider)
				sumary_body.querySelector(`#summary_provider_porcent_${provider.provider_id}`).textContent = `${final_porcent.porcent}%`
				sumary_body.querySelector(`#summary_provider_price_${provider.provider_id}`).textContent = `$${numberFormat.format(final_porcent.total)}`
			} else {
				this.add_provider_summary_table(provider)
			}
		}
		
		if( project_materials.list.length > 0 ){
			if (sumary_body.querySelector(`#summary_material_price`) != null) {
				sumary_body.querySelector(`#summary_material_price`).remove()
			}

			sumary_body.innerHTML += `
				<tr id="summary_material_price" class="">
	        <td>Materiales:</td>
	        <td>${project_materials.material_porcent()}%</td>
	        <td>$${ numberFormat.format(project_materials.sum_price()) }</td>
	      </tr>
			`
		}

		if ( sumary_body.querySelector(`#summary_total_price`) != null ) {
			sumary_body.querySelector(`#summary_total_price`).remove()
		}
		sumary_body.innerHTML += `
			<tr id="summary_total_price" class="g-font-size-20">
        <td colspan="2" ><b>Total: </b></td>
        <td ><b>$${ numberFormat.format(this.final_price) }</b></td>
      </tr>
		`
	},
	add_provider_summary_table({ provider_id, name, provider_porcent, total }){
		document.getElementById('summary-body').innerHTML += `
				<tr id='summary_provider_id_${provider_id}' >
					<td>${ name }</td>
					<td id='summary_provider_porcent_${provider_id}'>${provider_porcent}%</td>
					<td id='summary_provider_price_${provider_id}'>$${numberFormat.format(total)}</td>
				</tr>
			`
	},	
	calculate_subtotal(){
    // subtotal = sum providers price + sum material price
		const providers = project_providers.list.filter( element => element.type_total == 'price' )
		this.subtotal = providers.reduce( ( acc, element ) => acc + element.total, 0 )
		this.subtotal += project_materials.sum_price()
		project_providers.update_value_of_others_providers()
		document.getElementById('project_subtotal').value = `$${numberFormat.format(this.subtotal)}`
    formatCurrency( $("#project_subtotal") )
		this.calculate_final_price()
	},
	calculate_final_price(){
    // final price = subtotal + sum other providers price
		const providers = project_providers.list.filter( element => element.type_total == 'subtotal' )
		this.final_price = providers.reduce( ( acc, element ) => acc + element.total, this.subtotal )
		document.getElementById('project_final_price').value = `$${numberFormat.format( this.final_price )}`
		if ( project_providers.list.length > 0 ) {
			project_providers.calcular_porcentaje_representa()
		}
    project_providers.update_tables()
		project_apples.calculate_price_land()
		this.update_summary_table()
	},
	get_price_quotas(){
		// cuando seteamos los valores de forma manual, le pasamos a land_project el valor de cada cuota
		let price = []
		const price_quotas = document.getElementsByClassName("quota_manually")
		for (let i = 0; i < price_quotas.length; i++) {
			price.push( parseFloat(price_quotas[i].value) )
		}
		return price
	},
	get_price_quotas_corner(){
		// cuando seteamos los valores de forma manual, le pasamos a land_project el valor de cada cuota
		let price = []
		const price_quotas = document.getElementsByClassName("quota_manually_corner")
		for (let i = 0; i < price_quotas.length; i++) {
			price.push( parseFloat(price_quotas[i].value) )
		}
		return price
	},
	set_finalized(event){
		document.getElementById('project_land_price').disabled = !event.target.checked
		document.getElementById('check_set_final_price').classList.toggle("d-none", !event.target.checked)
		document.getElementById('label_corner').classList.toggle('d-none', !event.target.checked)
		document.getElementById('land_corner_input').classList.toggle('d-none', !event.target.checked)
		document.getElementById('payment_plan_input').classList.toggle('d-none', event.target.checked)
		if(event.target.checked){
			document.getElementById('land_price_text').innerHTML = "Valor que se registrara como pagado por lote."
		} else {
			document.getElementById('land_price_text').innerHTML = "Valor sugerido para el plan de pago."
		}
		
	},
	set_final_price_manual(){
		document.getElementById('project_final_price').disabled = !event.target.checked
		if (!event.target.checked) {
			this.calculate_final_price()
		} else {
			
		}
	},
	update_final_price_manual(){
		if( document.getElementById('project_set_final_price').checked ){
			this.subtotal = string_to_float('project_final_price')
			this.final_price = string_to_float('project_final_price')
			project_apples.calculate_price_land()
		}
	},
	check_all() {		
		let apples_added = document.getElementsByClassName("apple-added")
		for (let checkbox in apples_added) {
			apples_added[checkbox].checked = event.target.checked
		}
	},
}

$(document).ready(function(){
	$('.select-2-project-provider').select2({ width: '100%',theme: "bootstrap4", language: "es" })	
	$('.select-2-provider-role').select2({ width: '100%',theme: "bootstrap4", language: "es" })	
	$('.select-2-payment-method').select2({ width: '100%',theme: "bootstrap4", language: "es" })	
	$('.select-2-project-material').select2({ width: '100%',theme: "bootstrap4",placeholder: "Material",language: "es" })
	$('.select-2-project-material-unit').select2({ width: '100%',theme: "bootstrap4",placeholder: "Unidad medida",language: "es" })
	$('.select-2-project-type').select2({ width: '100%',theme: "bootstrap4", language: "es" })	
	$('.select-2-apple-list').select2({ width: '100%',theme: "bootstrap4", placeholder: "Todas seleccionadas", language: "es" })

	if (document.getElementById("project_date") != null) {
		setInputDate("#project_date")
		setInputDate("#payment_plan_date")
	}

	if( document.getElementById('project_final_price') != null ){
		document.getElementById('project_final_price').disabled = true
	}

	if (document.getElementById('project_first_pay_required') != null) {
		document.getElementById('project_first_pay_required').addEventListener('click', () => {
			if (event.target.checked) {
				document.getElementById('project_first_pay_price').classList.remove('d-none')
				document.getElementById('project_first_pay_price').value = ''
			} else {
				document.getElementById('project_first_pay_price').classList.add('d-none')
				document.getElementById('project_first_pay_price').value = 0
			}
		})
	}
})

