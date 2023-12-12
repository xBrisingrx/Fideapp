let projects_table;
let project = {
	materials_list:[],
	providers_list:[],
	project_price: '',
	subtotal: 0,
	final_price: 0,
	apples:[],
	sectors:[],
	cant_lands:0,
	cant_corners:0,
	land_price:0,
	land_corner_price:0,
	apple_has_corner: false,
	form: new FormData(),
	add_provider( type_total ){
		event.preventDefault()
		let provider = {
			provider_id: parseInt( document.getElementById('project_provider_id').value ),
			provider_role: parseInt( document.getElementById('project_provider_role').value ),
			payment_method_id: parseInt( document.getElementById('project_payment_method').value ),
			provider_price: parseFloat(document.getElementById('project_provider_price').value),
			provider_iva: parseFloat( document.getElementById('provider_iva').value ),
			type_total: type_total
		}

		if ( this.provider_validations(provider) ) {
			provider.name = $('#project_provider_id option:selected').text()
			provider.role_name =  $('#project_provider_role option:selected').text()
			provider.payment_method_name =  $('#project_payment_method option:selected').text()
			provider.provider_price_text = ( provider.payment_method_id == 1 ) ? `$${numberFormat.format(provider.provider_price)}` : `${provider.provider_price}%`
			provider.provider_price_calculate = this.calcular_precio_proveedor( provider )
			provider.value_iva = this.calculate_value_iva(provider)
			provider.provider_porcent = 0
			provider.total = provider.value_iva + provider.provider_price_calculate
			provider.list_id = `${provider.provider_id}_${type_total}`

			this.providers_list.push( provider )

			this.disabled_and_reset_select('project_provider_id' , 'select-2-project-provider')
			$(`.select-2-provider-role`).val('').trigger('change')
			$(`.select-2-payment-method`).val('').trigger('change')
			document.getElementById('project_provider_price').value = ''

			this.calculate_subtotal()
		}
	},
	add_other_provider( type_total ) {
		event.preventDefault()
		let provider = {
			provider_id: parseInt( document.getElementById('project_other_provider_id').value ),
			provider_role: parseInt( document.getElementById('project_other_provider_role').value ),
			provider_price: parseFloat(document.getElementById('project_other_provider_price').value),
			provider_iva: parseFloat( document.getElementById('other_provider_iva').value ),
			type_total: type_total,
			payment_method_id: 2
		}
		if ( this.provider_validations(provider) ) {
			provider.name =  $('#project_other_provider_id option:selected').text()
			provider.role_name =  $('#project_other_provider_role option:selected').text()
			provider.provider_price_calculate = this.calcular_precio_proveedor( provider )
			provider.value_iva = this.calculate_value_iva(provider)
			provider.provider_porcent = 0
			provider.total = provider.value_iva + provider.provider_price_calculate
			provider.list_id = `${provider.provider_id}_${type_total}`

			this.providers_list.push( provider )
			this.calculate_final_price()
			this.update_other_providers_table()
			// this.disabled_and_reset_select('project_provider_id' , 'select-2-project-provider')
			$(`.select-2-provider-other-role`).val('').trigger('change')
			document.getElementById('project_provider_price').value = ''
			document.getElementById('table_other_provider').classList.remove('d-none')
		}
	},
	remove_provider( id ) {
		event.preventDefault()
		this.providers_list = this.providers_list.filter( p => p.list_id != `${id}_price` )
		let element = document.querySelector(`#provider-list #row-${id}`)
		element.remove()
		$(`#project_provider_id option[value='${id}']`).attr('disabled', false)
		this.calculate_subtotal()
		this.remove_provider_summary_table(id)
		this.update_summary_table()
	},
	remove_other_provider( id ) {
		event.preventDefault()
		this.providers_list = this.providers_list.filter( p => p.list_id != `${id}_subtotal` )
		this.calculate_subtotal()
		let element = document.querySelector(`#other-provider-list #row-${id}`)
		element.remove()
		let other_providers = this.providers_list.filter( p => p.type_total == 'subtotal' )
		if (other_providers.length == 0) {
			document.getElementById('table_other_provider').classList.add('d-none')
		}
		this.calculate_subtotal()
		this.remove_provider_summary_table(id)
		this.update_summary_table()
	},
	change_method_cobro(){
		const selected = event.target.value
		const nodo = event.target.parentElement.parentElement
		const provider_selected_id = nodo.getElementsByClassName('provider-id').item(0).dataset.id
		const delete_btn = event.target.parentElement.parentElement.querySelector(`#delete_provider_${provider_selected_id}`)
		this.remove_inputs(nodo, provider_selected_id)
		if (selected === 'porcent') {
			const providers = this.get_name_providers(provider_selected_id)
			let options_generate = ''
			if (providers.length == 0 ) {
				noty_alert('warning', 'No hay otros proveedores seleccionados')
				return
			}
			providers.forEach( function(p) {
				options_generate += `<option value="${p}">${p}</option>`
			})
			// options_generate += providers.map( p => `<option>${p}</option>` )
			let select_providers = document.createElement("select")
			select_providers.id = "list_providers_generate"
			select_providers.className = 'ml-2 mr-2'
			nodo.insertBefore(select_providers, delete_btn )

			this.add_number_input(nodo,delete_btn, false, 'col-2', 'porcent_input')

			nodo.querySelector('#list_providers_generate').innerHTML += options_generate
			this.add_number_input(nodo,delete_btn, true, 'col-4', 'provider_price', 'Calculo segun %')
		} else if (selected === 'fix_number') {
			this.add_number_input(nodo,delete_btn, false, 'col-4', 'provider_price')
		} else {
			console.log('valor invalido')
		}
	},
	get_id_providers(){
		let proveedores = []
		let lista = document.getElementsByClassName('provider-id')
		for (let i = lista.length - 1; i >= 0; i--) {
			proveedores.push(lista[i].dataset.id)
		}
		return proveedores
	},
	get_name_providers(provider_id){
		let proveedores = []
		let lista = document.getElementsByClassName('provider-id')
		for (let i = lista.length - 1; i >= 0; i--) {
			if (lista[i].dataset.id != provider_id) {
				proveedores.push(lista[i].value)
			}
		}
		return proveedores
	},
	// ### MATERIALS
	add_material(){
		event.preventDefault()
		let material = {
			id: parseInt(document.getElementById('project_material_id').value),
			type_units: document.getElementById('type_unit').value,
			units: parseInt( document.getElementById('material_units').value ),
			price: parseFloat( document.getElementById('material_price').value )
		}

		if (material.id == null || material.id == '') {
			noty_alert('error', 'Error al agregar el material a la lista')
			return
		}
		if ( material.units == null || isNaN(material.units)) {
			noty_alert('error', 'Las unidades deben ser un numero')
			return
		}
		if ( material.price == null || isNaN(material.price) ) {
			noty_alert('error', 'El precio debe ser un numero')
			return
		}

		let material_name =  $('#project_material_id option:selected').text()
		$('.project-material-body').append(`
			<tr id="row-${material.id}">
				<td>${material_name}</td>
				<td>${material.type_units}</td>
				<td>${material.units}</td>
				<td>${numberFormat.format(material.price)}</td>
				<td><b>$${numberFormat.format(material.price * material.units)}</b></td>
				<td><button type="button" class="btn u-btn-red remove-material" onclick="project.remove_material(${material.id})" 
					title="Quitar material"> <i class="fa fa-trash"></i> </button></td>
			</tr>
		`)
		this.materials_list.push( material )
		$('#project_material_id option:selected').attr('disabled', 'disabled')
		$('.select-2-project-material').val('').trigger('change')
		document.getElementById('material_units').value = 0
		document.getElementById('material_price').value = 0
		this.calculate_subtotal()
	},
	remove_material(material_id){
		event.preventDefault()
		let element = document.querySelector(`.project-material-body #row-${material_id}`)
		element.remove()
		$(`#project_material_id option[value='${material_id}']`).attr('disabled', false)
		this.materials_list = this.materials_list.filter( m => m.id != material_id )
		this.calculate_subtotal()
	},
	sum_material_price(){
		let material_price = 0
		for (let i = 0; i < this.materials_list.length; i++){
			material_price += (this.materials_list[i].units * this.materials_list[i].price)
		}
		return material_price
	},
	material_porcent(){
		const price_materials = this.sum_material_price()
		return (( price_materials * 100 ) / this.final_price ).toFixed(2)
	},
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
	submit(){
		event.preventDefault()
		event.stopPropagation()
		this.form.append('project[date]', document.getElementById('project_date').value )
		this.form.append('project[number]', document.getElementById('project_number').value )
		this.form.append('project[name]', document.getElementById('project_name').value )
		this.form.append('project[price]', project.project_price )
		this.form.append('project[final_price]', parseFloat( this.final_price ) )
		this.form.append('project[subtotal]', parseFloat( this.subtotal ) )
		this.form.append('project[description]', document.getElementById('project_description').value )
		this.form.append('project[project_type_id]', parseInt(document.getElementById('project_project_type_id').value ) )
		this.form.append('project[number_of_payments]', parseInt(document.getElementById('project_number_of_payments').value ) )
		this.form.append('project[finalized]', document.getElementById('project_finalized').checked )

		this.form.append('project[land_price]', parseFloat( document.getElementById('project_land_price').value ) )
		this.form.append('project[land_corner_price]', parseFloat( document.getElementById('project_land_corner_price').value ) )
		this.form.append('project[first_pay_required]', document.getElementById('project_first_pay_required').checked )
		this.form.append('project[first_pay_price]', parseFloat(document.getElementById('project_first_pay_price').value))
		if ( document.getElementById('project_enter_quotas_manually').checked ) {
			// le ponemos el valor de cada cuota cuando se agrega el lote
			this.form.append('project[price_fee]', 0)
			this.form.append('project[price_fee_corner]', 0 )
		} else {
			this.form.append('project[price_fee]', parseFloat( document.getElementById('project_price_fee').value ) )
			this.form.append('project[price_fee_corner]', parseFloat( document.getElementById('project_price_fee_corner').value ) )
		}

		this.add_providers()
		this.add_materials()
		this.add_apples_to_form()
		this.add_lands_to_form()
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
	charge_sectors(){
		const urbanization_id = document.getElementById("project_urbanization_id").value
		fetch(`/sectors/filter_for_urbanization/${urbanization_id}.json`).then( response => response.json() )
			.then( r => {
				let sector_list = document.querySelector('#sector_list')
				sector_list.innerHTML = '<option value=""> Elegir sector </option>'
				this.sectors = r.data
				for (let sector in this.sectors){
				  sector_list.innerHTML += `
				  	<option value='${this.sectors[sector].id}' data-cant='${this.sectors[sector].apples}' data-name='${this.sectors[sector].name}'>
				  		${this.sectors[sector].name} (${this.sectors[sector].apples})
				  	</option>
				  `
				}
		})
	},
	charge_apples(){
		const sector_id = this.sectors.filter( sector => sector.id == document.getElementById('sector_list').value )[0].id
		fetch(`/apples/filter_for_sector/${sector_id}.json`).then( response => response.json() ).then( r => {
			let apple_list = document.querySelector('#apple_list')
			apple_list.innerHTML = '<option value=""> Elegir manzana </option>'
			// this.apples = r.data
			// for (let lote in this.apples){
			//   apple_list.innerHTML += `
			//   	<option value='${this.apples[lote].id}' data-cant='${this.apples[lote].lands}' data-cant_corners='${this.apples[lote].count_corners}' > ${this.apples[lote].code} </option>
			//   `
			// }
			document.getElementById("list_of_apples").innerHTML = ''
			document.getElementById("select_all_apples").checked = true
			if (r.data.length > 0) {
				document.getElementById("show_apple_list").disabled = false;
				for (let index = 0; index < r.data.length; index++) {
					const element = r.data[index];
					if ( element.lands === 0 ) { continue }

					document.getElementById("list_of_apples").innerHTML += `
					<div class="col-3">
						<div class="form-group g-mb-10 g-mb-0--md">
							<label class="u-check g-pl-25">
								<input class="g-hidden-xs-up g-pos-abs g-top-0 g-left-0" type="checkbox" checked data-apple-id=${element.id}>
								<div class="u-check-icon-checkbox-v4 g-absolute-centered--y g-left-0">
									<i class="fa" data-check-icon=""></i>
								</div>
								${element.code}
							</label>
						</div>
					</div>
					`
				}
			} else {
				document.getElementById("show_apple_list").disabled = true;
			}
		})
	},
	provider_validations({provider_id, provider_role,payment_method_id,provider_price, provider_iva}){
		if (isNaN(provider_id)) {
			noty_alert('error', 'Debe seleccionar un proveedor')
			// provider_id.classList.add('g-brd-pink-v2--error')
			return false
		}
		if ( isNaN(provider_role) ) {
			noty_alert('error', 'Debe seleccionar funcion')
			return false
		}
		if ( isNaN(payment_method_id) ) {
			noty_alert('error', 'Debe seleccionar metodo de pago')
			return false
		}
		if ( isNaN( provider_price ) ) {
			noty_alert('error', 'Debe ingresar monto valido')
			return false
		}
		if ( isNaN( provider_iva ) ) {
			noty_alert('error', 'Debe seleccionar el IVA')
			return false
		}

		if ( !( this.project_price > 0 ) ) {
			noty_alert('warning', 'El projecto no tiene precio')
			return false
		}

		return true
	},
	disabled_and_reset_select(select_id, select_class){
		$(`#${select_id} option:selected`).attr('disabled', 'disabled')
		$(`.${select_class}`).val('').trigger('change')
	},
	calcular_precio_proveedor({payment_method_id,provider_price, type_total}){
		if (payment_method_id == 2) { // porcentaje
			const porcent = provider_price/100
			const price = ( type_total == 'price' ) ? this.project_price : this.subtotal
			return (price * porcent)
		} else { // valor fijo
			return provider_price
		}
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
	calcular_porcentaje_representa(){
		if ( this.final_price > 0 ) {
			for (let i = 0; i < this.providers_list.length; i++){
				if (this.providers_list[i].type_total == 'price') {
					this.providers_list[i].provider_porcent = ( ( this.providers_list[i].total * 100 ) / this.subtotal ).toFixed(2)
				} else {
					this.providers_list[i].provider_porcent = ( ( this.providers_list[i].total * 100 ) / this.final_price ).toFixed(2)
				}
			}
		} else {
			noty_alert('warning', 'El valor del proyecto debe ser mayor a 0')
			return `Valor de proyecto invalido`
		}
	},
	represent_final_porcent({total}){
		return ( ( total * 100 ) / this.final_price ).toFixed(2)
	},
	update_providers_table(){
		// actualizamos el valor en la tabla
		let table_body = document.querySelector('#provider-list')
		for (let i = 0; i < this.providers_list.length; i++){
			let provider = this.providers_list[i]
			if (provider.type_total == 'price') {
				if ( table_body.querySelector(`#row-${provider.provider_id}`) != null ) {// si ya esta en la tabla solo actualizamos el %
				table_body.querySelector(`#row-${provider.provider_id} #porcentaje_representa_${provider.provider_id}`).innerHTML = `${provider.provider_porcent}%`
				} else {
					table_body.innerHTML += `
						<tr id="row-${provider.provider_id}">
							<td>${provider.name}</td>
							<td>${provider.role_name}</td>
							<td>${provider.payment_method_name}</td>
							<td>${provider.provider_price_text}</td>
							<td> $${numberFormat.format(provider.provider_price_calculate)} </td>
							<td>${provider.provider_iva}%</td>
							<td>$${ numberFormat.format(provider.value_iva) }</td>
							<td> <b>$${ numberFormat.format(provider.total ) }</b> </td>
							<td id="porcentaje_representa_${provider.provider_id}"> ${provider.provider_porcent}% </td>
							<td><button type="button" class="btn u-btn-red remove-provider" onclick="project.remove_provider(${provider.provider_id})" 
							title="Quitar interviniente"> <i class="fa fa-trash"></i> </button></td>
						</tr>
					`
				}
			}
		}
	},
	update_other_providers_table(){
		// actualizamos la tabla de otro proveedores
		let table_body = document.querySelector('#other-provider-list')
		for (let i = 0; i < this.providers_list.length; i++){
			let provider = this.providers_list[i]
			if (provider.type_total == 'subtotal') {
				let tr_content = `
					<td>${provider.name}</td>
					<td>${provider.role_name}</td>
					<td>${provider.provider_price}%</td>
					<td> $${numberFormat.format(provider.provider_price_calculate)} </td>
					<td>${provider.provider_iva}%</td>
					<td>$${ numberFormat.format(provider.value_iva) }</td>
					<th> $${ numberFormat.format( provider.total) } </td>
					<td id="porcentaje_representa_${provider.provider_id}"> ${provider.provider_porcent}% </td>
					<td><button type="button" class="btn u-btn-red remove-provider" onclick="project.remove_other_provider(${provider.provider_id})" 
					title="Quitar interviniente"> <i class="fa fa-trash"></i> </button></td>
				`
				if ( table_body.querySelector(`#row-${provider.provider_id}`) != null ) {
					table_body.querySelector(`#row-${provider.provider_id}`).innerHTML = tr_content
				} else {
					table_body.innerHTML += `
						<tr id="row-${provider.provider_id}">${tr_content}</tr>
					`
				}
			}
		}
	},
	update_summary_table(){ // actualizamos la tabla RESUMEN
		if ($('#project_project_type_id option:selected').val() == '') {
			noty_alert('info', 'Por favor seleccione el tipo de proyecto')
			return
		}
		if (isNaN(this.final_price) || this.final_price == 0) {
			// hago una salvedad para cuando seleccionan el tipo de proyecto 
			// en tipo de proyecto tengo un onchange por si sucede que ingresan valor al proyecto pero no seleccionaron el tipo de proyecto
			return
		}
		// agregamos o en caso de ya haber sido agregada actualizamos el precio y % que representa el valor del proyecto
		let sumary_body = document.getElementById('summary-body')
		const project_porcent = `${ ((this.project_price * 100) / this.final_price).toFixed(2) }%`
		const project_price = `$${numberFormat.format(this.project_price)}`
		if ( sumary_body.querySelector(`#project_price_row`) != null ) {
			sumary_body.querySelector(`#project_price_row`).textContent = project_price
			sumary_body.querySelector(`#project_porcent_row`).textContent = project_porcent
		} else {
			document.getElementById('summary-body').innerHTML += `
				<tr>
					<td id='project_name'>${ $('#project_project_type_id option:selected').text() }</td>
					<td id='project_porcent_row'>${project_porcent}</td>
					<td id='project_price_row'>${project_price}</td>
				</tr>
			`
		}
		// agregamos o en caso de ya haber sido agregada actualizamos el precio y % que representa c/interviniente
		for (let i = 0; i < this.providers_list.length; i++){
			let provider = this.providers_list[i]
			if ( sumary_body.querySelector(`#summary_provider_id_${provider.provider_id}`) != null ) {
				sumary_body.querySelector(`#summary_provider_porcent_${provider.provider_id}`).textContent = `${this.represent_final_porcent(provider)}%`
				sumary_body.querySelector(`#summary_provider_price_${provider.provider_id}`).textContent = `$${numberFormat.format(provider.total)}`
			} else {
				this.add_provider_summary_table(provider)
			}
		}
		if (sumary_body.querySelector(`#summary_material_price`) != null) {
			sumary_body.querySelector(`#summary_material_price`).remove()
		}

		sumary_body.innerHTML += `
			<tr id="summary_material_price" class="">
        <td>Materiales:</td>
        <td>${this.material_porcent()}%</td>
        <td>$${ numberFormat.format(this.sum_material_price()) }</td>
      </tr>
		`

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
	add_provider_summary_table(provider_data){
		document.getElementById('summary-body').innerHTML += `
				<tr id='summary_provider_id_${provider_data.provider_id}' >
					<td>${ provider_data.name }</td>
					<td id='summary_provider_porcent_${provider_data.provider_id}'>${provider_data.provider_porcent}%</td>
					<td id='summary_provider_price_${provider_data.provider_id}'>$${numberFormat.format(provider_data.total)}</td>
				</tr>
			`
	},
	remove_provider_summary_table(provider_id){
		document.getElementById(`summary_provider_id_${provider_id}`).remove()
	},
	add_providers(){
		// this.form.append(`cant_providers`, this.providers_list.length)
		for (let i = 0; i < this.providers_list.length; i++){
			this.form.append( `project[project_providers_attributes][${i}][provider_id]` , this.providers_list[i].provider_id)
			this.form.append( `project[project_providers_attributes][${i}][provider_role_id]` , this.providers_list[i].provider_role)
			this.form.append( `project[project_providers_attributes][${i}][payment_method_id]` , this.providers_list[i].payment_method_id)
			this.form.append( `project[project_providers_attributes][${i}][price]` , this.providers_list[i].provider_price)
			this.form.append( `project[project_providers_attributes][${i}][iva]` , this.providers_list[i].provider_iva)
			this.form.append( `project[project_providers_attributes][${i}][value_iva]` , this.providers_list[i].value_iva)
			this.form.append( `project[project_providers_attributes][${i}][price_calculate]` , this.providers_list[i].provider_price_calculate)
			this.form.append( `project[project_providers_attributes][${i}][porcent]` , this.providers_list[i].provider_porcent)
			this.form.append( `project[project_providers_attributes][${i}][type_total]` , this.providers_list[i].type_total)
		}
	},
	add_materials(){
		// this.form.append(`cant_materials`, this.materials_list.length)
		for (let i = 0; i < this.materials_list.length; i++){
			this.form.append( `project[project_materials_attributes][${i}][material_id]` , this.materials_list[i].id)
			this.form.append( `project[project_materials_attributes][${i}][type_units]` , this.materials_list[i].type_units)
			this.form.append( `project[project_materials_attributes][${i}][units]` , this.materials_list[i].units)
			this.form.append( `project[project_materials_attributes][${i}][price]` , this.materials_list[i].price)
		}
	},
	add_apples_to_form(){
		const apples = document.getElementsByClassName("apples-adds")
		for (let i = 0; i < apples.length; i++) {
			this.form.append( `project[apple_projects_attributes][${i}][apple_id]` , apples[i].value)
		}
	},
	add_lands_to_form(){
		const lands = document.getElementsByClassName("land")
		let price_quotas = [] 
		price_quotas = this.get_price_quotas()
		let price_quotas_corner = []
		price_quotas_corner = this.get_price_quotas_corner()
		for (let i = 0; i < lands.length; i++) {
			if (lands[i].checked) {
				const land_price = ( lands[i].dataset.corner ) ? this.form.get('project[land_corner_price]') : this.form.get('project[land_price]')
				this.form.append( `project[land_projects_attributes][${i}][land_id]` , lands[i].dataset.landId)
				this.form.append( `project[land_projects_attributes][${i}][price]` , land_price)
				this.form.append( `project[land_projects_attributes][${i}][price_quotas][]` , price_quotas )
				this.form.append( `project[land_projects_attributes][${i}][price_quotas_corner][]` , price_quotas_corner )
			}
		}
	},
	calculate_subtotal(){
		this.subtotal = this.project_price
		for (let i = 0; i < this.providers_list.length; i++){
			if ( this.providers_list[i].type_total == 'price' ) {
				this.subtotal += this.providers_list[i].total
			}
		}
		this.subtotal += this.sum_material_price()
		document.getElementById('project_subtotal').value = `$${numberFormat.format(this.subtotal)}`
		this.calculate_final_price()
	},
	calculate_final_price(){
		this.final_price = this.subtotal 
		for (let i = 0; i < this.providers_list.length; i++){
			if ( this.providers_list[i].type_total == 'subtotal' ) {
				this.final_price += this.providers_list[i].total
			}
		}
		document.getElementById('project_final_price').value = `$${numberFormat.format( this.final_price )}`
		if ( this.providers_list.length > 0 ) {
			this.calcular_porcentaje_representa()
			this.update_providers_table()
			this.update_other_providers_table()
		}
		this.calculate_price_land()
		this.update_summary_table()
	},
	set_porcent_values(){

	},
	add_apple(){ // adds apples and lands to form
		let apple_selected = this.apples.filter( apple => apple.id == document.getElementById('apple_list').value )[0]
		let land_list = ''
		let apple_detail = `${$( "#project_urbanization_id option:selected" ).text()} ${$( "#sector_list option:selected" ).data('name')} ${$("#apple_list option:selected").text()}`
		fetch(`/apples/${apple_selected.id}/lands.json`)
		.then( response => response.json() )
		.then( response => {
			response.data.forEach( land => {
				land_list += `<div class="form-group">
			    <label class="form-check-inline u-check g-pl-25">
			      <input class="land g-hidden-xs-up g-pos-abs g-top-0 g-left-0" type="checkbox" data-land-id="${land.id}" value="1" name="project[land_${land.id}]" id="project_land_${land.id}" />
			      <div class="u-check-icon-checkbox-v6 g-absolute-centered--y g-left-0">
			        <i class="fa" data-check-icon="&#xf00c"></i>
			      </div>
			      ${land.code}
			    </label>
			  </div>`
			} )
		} )

		console.log(land_list)

		$('#accordion-lands').append(`
		  <!-- Card -->
  <div class="card g-brd-none rounded-0 g-mb-15">
    <div id="accordion-lands-heading-${apple_selected.id}" class="u-accordion__header g-pa-0" role="tab">
      <h5 class="mb-0">
        <a class="d-flex g-color-main g-text-underline--none--hover g-brd-around g-brd-gray-light-v4 g-rounded-5 g-pa-10-15" 
        href="#accordion-lands-body-${apple_selected.id}" aria-expanded="true" 
        aria-controls="accordion-lands-body-${apple_selected.id}" 
        data-toggle="collapse" 
        data-parent="#accordion-lands">
          <span class="u-accordion__control-icon g-mr-10">
            <i class="fa fa-angle-down"></i>
            <i class="fa fa-angle-up"></i>
          </span>
          ${apple_detail}
        </a>
      </h5>
    </div>
    <div id="accordion-lands-body-${apple_selected.id}" class="collapse show" role="tabpanel" aria-labelledby="accordion-lands-heading-${apple_selected.id}" data-parent="#accordion-lands">
      <div class="u-accordion__body g-color-gray-dark-v5">
        ${land_list}
      </div>
    </div>
  </div>
  <!-- End Card -->

		`)
		this.calculate_price_land()
	},
	remove_apple(apple_id){
		document.getElementById(`apple-${apple_id}`).remove()
	},
	calculate_price_land(){
		if ( document.getElementById("project_final_price").value <= 0 ) {
			noty_alert("info", "Debe ingresar el valor al proyecto")
			return
		}
		const lands = document.getElementsByClassName("land")
		if (lands.length == 0) {
			return
		}
		let cant_lands = 0
		for (let i = 0; i < lands.length; i++) {
			if (lands[i].checked)
			cant_lands ++
		}
		const land_price = (this.final_price/cant_lands).toFixed(2)
		document.getElementById('project_land_price').value = land_price
		document.getElementById('project_land_corner_price').value = land_price
	},
	calculate_value_iva({provider_iva, provider_price_calculate}) {
		return ( provider_iva * provider_price_calculate ) / 100
	},
	show_months_payments(){
		const month_of_payments = document.getElementById("month_of_payments")

		if ( document.getElementById("project_first_pay_required").checked && !valid_number(document.getElementById('project_first_pay_price').value) ) {
			month_of_payments.innerHTML = ''
			return
		}
		if( !valid_number(document.getElementById("project_number_of_payments").value)  ) {
			month_of_payments.innerHTML = ''
			return
		}

		let date = new Date(`${document.getElementById("project_date").value}T00:00:00`)
		const number_of_payments = document.getElementById("project_number_of_payments").value
		
		let payment_value,first_pay_price,project_land_price
		if (document.getElementById('project_enter_quotas_manually').checked) {
			payment_value = this.get_price_quotas()
		} else {
			first_pay_price = ( document.getElementById("project_first_pay_required").checked ) ? parseFloat(document.getElementById('project_first_pay_price').value) : 0
			project_land_price = parseFloat(document.getElementById("project_land_price").value) - first_pay_price
			payment_value = roundToTwo(( project_land_price / number_of_payments))
		}
		month_of_payments.innerHTML = ''
		for (let i = 0; i < number_of_payments; i++) {
			let month = date.getMonth()
			if ( document.getElementById('project_enter_quotas_manually').checked ) {
				if (!valid_number(payment_value[i])) {
					return
				}
				month_of_payments.innerHTML += `
					<div class="g-brd-blue-left u-shadow-v2 g-brd-around g-brd-gray-light-v4 g-line-height-2 g-pa-10 g-mb-30 col-8 col-sm-4 col-md-3 g-mr-5">
	          <p class="mb-0 name"><strong>Mes:</strong> ${meses[month]}-${date.getFullYear()}</p>
	          <p class="mb-0 relationship"><strong>Valor cuota:</strong> $${ numberFormat.format(payment_value[i]) }</p>
	        </div>
				`
			} else {
				month_of_payments.innerHTML += `
					<div class="g-brd-blue-left u-shadow-v2 g-brd-around g-brd-gray-light-v4 g-line-height-2 g-pa-10 g-mb-30 col-8 col-sm-4 col-md-3 g-mr-5">
	          <p class="mb-0 name"><strong>Mes:</strong> ${meses[month]}-${date.getFullYear()}</p>
	          <p class="mb-0 relationship"><strong>Valor cuota:</strong> $${ numberFormat.format(payment_value) }</p>
	        </div>
				`
			}
			date.setMonth( date.getMonth() + 1 )
		}
		this.set_fee_value()
	},
	set_fee_value(){
		let first_pay
		if (document.getElementById("project_first_pay_required").checked && !valid_number(document.getElementById('project_first_pay_price').value)) {
			return
		} else {
			first_pay_price = ( document.getElementById("project_first_pay_required").checked ) ? parseFloat(document.getElementById('project_first_pay_price').value) : 0
		}
		const land_price = parseFloat(document.getElementById("project_land_price").value) - first_pay_price
		const corner_price = parseFloat(document.getElementById("project_land_corner_price").value) - first_pay_price
		const number_of_payments = parseInt(document.getElementById("project_number_of_payments").value)

		document.getElementById("project_price_fee").value = ( land_price/number_of_payments ).toFixed(2)
		document.getElementById("project_price_fee_corner").value = ( corner_price/number_of_payments ).toFixed(2)
	},
	enter_quotas_manually(){
		this.show_months_payments()
		const quotas = parseInt( document.getElementById("project_number_of_payments").value )
		document.getElementById("enter_quotas_manually").innerHTML = ''
		if (!valid_number( quotas )) {
			event.target.checked = false
			noty_alert('info', 'Debe ingresar cantidad de cuotas')
			return
		}

		if (!valid_number( this.final_price )) {
			event.target.checked = false
			noty_alert('info', 'El proyecto no tiene precio')
			return
		}

		if ( event.target.checked ) {
			const enter_quotas_manually = document.getElementById("enter_quotas_manually")
			document.getElementById("project_price_fee").parentElement.parentElement.classList.add("d-none")
			for (let i = 1; i < quotas+1; i++) {
				enter_quotas_manually.innerHTML += `
					<div class="form-group row">
				    <label> Cuota #${i} </label>
				    <input placeholder="Valor cuota lote" class="form-control rounded-0 col-4 ml-2 quota_manually" type="text" name="project_quota_${i}" onchange="project.check_quota_value()">
				    <input placeholder="Valor cuota esquina" class="form-control rounded-0 col-4 ml-2 quota_manually_corner" type="text" name="project_quota_${i}">
				    <div class="invalid-feedback"></div>
				  </div>
				`
			}
		} else {
			document.getElementById("project_price_fee").parentElement.parentElement.classList.remove("d-none")
		}
	},
	check_quota_value(){
		if ( valid_number(event.target.value) ) {
			event.target.parentElement.querySelector(".quota_manually_corner").value = event.target.value
		} else {
			event.target.classList.add('is-invalid')
		}
		this.show_months_payments()
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
	}
}

$(document).ready(function(){
	$('.select-2-project-provider').select2({ width: '100%',theme: "bootstrap4", language: "es" })	
	$('.select-2-provider-role').select2({ width: '100%',theme: "bootstrap4", language: "es" })	
	$('.select-2-payment-method').select2({ width: '100%',theme: "bootstrap4", language: "es" })	
	$('.select-2-project-material').select2({ width: '100%',theme: "bootstrap4", language: "es" })	
	$('.select-2-project-type').select2({ width: '30%',theme: "bootstrap4", language: "es" })	
	$('.select-2-apple-list').select2({ width: '100%',theme: "bootstrap4", placeholder: "Todas seleccionadas", language: "es" })
	$("#projects_table").DataTable({
		'language': {'url': "/assets/plugins/datatables_lang_spa.json"}
	})

	if (document.getElementById("project_date") != null) {
		setInputDate("#project_date")
	}

	if (document.getElementById('project_first_pay_required') != null) {
		document.getElementById('project_first_pay_required').addEventListener('click', () => {
			if (event.target.checked) {
				project.show_months_payments()
				document.getElementById('project_first_pay_price').classList.remove('d-none')
				document.getElementById('project_first_pay_price').value = ''
			} else {
				project.show_months_payments()
				document.getElementById('project_first_pay_price').classList.add('d-none')
				document.getElementById('project_first_pay_price').value = 0
			}
		})
	}
})



async function async_add_apples(){ // adds apples and lands to form
	let apple_selected = project.apples.filter( apple => apple.id == document.getElementById('apple_list').value )[0]
	if (document.getElementById(`apple-${apple_selected.id}`) != null) {
		noty_alert("info", "Esta manzana ya esta agregada")
		return
	}
		let land_list = '<div class="row">'
		let apple_detail = `${$( "#project_urbanization_id option:selected" ).text()} ${$( "#sector_list option:selected" ).data('name')} ${$("#apple_list option:selected").text()}`
		const response = await fetch(`/apples/${apple_selected.id}/lands.json`)
		const data = await response.json() 
		data.data.forEach( land => {
				land_list += `<div class="form-group col-3">
			    <label class="form-check-inline u-check g-pl-25">
			      <input class="land g-hidden-xs-up g-pos-abs g-top-0 g-left-0" type="checkbox" data-land-id="${land.id}" data-corner=${land.is_corner} value="1" checked name="project[land_${land.id}]" id="project_land_${land.id}" onclick="project.calculate_price_land()" />
			      <div class="u-check-icon-checkbox-v6 g-absolute-centered--y g-left-0">
			        <i class="fa" data-check-icon="&#xf00c"></i>
			      </div>
			      ${land.code}
			    </label>
			  </div>`
			} )

		land_list += "</div>"

		$('#accordion-lands').append(`
  <div id="apple-${apple_selected.id}" class="card g-brd-none rounded-0 g-mb-15">
    <div id="accordion-lands-heading-${apple_selected.id}" class="u-accordion__header g-pa-0" role="tab">
      <h5 class="mb-0">
        <a class="d-flex g-color-main g-text-underline--none--hover g-brd-around g-brd-gray-light-v4 g-rounded-5 g-pa-10-15" 
        href="#accordion-lands-body-${apple_selected.id}" aria-expanded="true" 
        aria-controls="accordion-lands-body-${apple_selected.id}" 
        data-toggle="collapse" 
        data-parent="#accordion-lands">
          <span class="u-accordion__control-icon g-mr-10">
            <i class="fa fa-angle-down"></i>
            <i class="fa fa-angle-up"></i>
          </span>
          ${apple_detail}
        </a>
      </h5>
    </div>
    <div id="accordion-lands-body-${apple_selected.id}" class="collapse show" role="tabpanel" aria-labelledby="accordion-lands-heading-${apple_selected.id}" data-parent="#accordion-lands">
			<input class="apples-adds" type="hidden" value="${apple_selected.id}" />
      <div class="u-accordion__body g-color-gray-dark-v5">
        ${land_list}
      </div>
    </div>
  </div>
		`)
		project.calculate_price_land()
	}

