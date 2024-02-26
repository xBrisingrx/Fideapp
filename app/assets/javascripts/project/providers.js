let project_providers = {
  list: [],
  add(type_total){
    event.preventDefault()
		// provider is the first table and other_provider is the second provider table
		// other providers calculate her porcent with subtotal project

		const provider_type = ( type_total == 'price') ? 'provider' : 'other_provider'
		let provider = {
			provider_id: parseInt( document.getElementById(`project_${provider_type}_id`).value ),
			provider_role: parseInt( document.getElementById(`project_${provider_type}_role`).value ),
			payment_method_id: ( type_total == 'price') ? 1 : 2,
			provider_price: string_to_float(`project_${provider_type}_price`),
			provider_iva: parseFloat( document.getElementById(`${provider_type}_iva`).value ),
			type_total: type_total
		}

		if ( this.validations(provider) ) {
			provider.name = $(`#project_${provider_type}_id option:selected`).text()
			provider.role_name =  $(`#project_${provider_type}_role option:selected`).text()
			provider.provider_price_text = ( provider.payment_method_id == 1 ) ? `$${numberFormat.format(provider.provider_price)}` : `${provider.provider_price}%`
			provider.provider_price_calculate = this.calculate_price( provider )
			provider.value_iva = this.calculate_value_iva(provider)
			provider.provider_porcent = 0
			provider.total = roundToTwo(provider.value_iva + provider.provider_price_calculate)
			provider.list_id = `${provider.provider_id}_${provider.provider_role}_${type_total}`

			this.list.push( provider )
			
			$('.select-2-project-provider').val('').trigger('change')
			$('.select-2-provider-role').val('').trigger('change')
			$('.select-2-payment-method').val('').trigger('change')
			document.getElementById('project_provider_price').value = ''

			project.calculate_subtotal()
		}
  },
  validations({provider_id, provider_role,provider_price, provider_iva, list_id}){
		if (isNaN(provider_id)) {
			noty_alert('warning', 'Debe seleccionar un proveedor')
			return false
		}
		if ( isNaN(provider_role) ) {
			noty_alert('warning', 'Debe seleccionar funcion')
			return false
		}

		if ( !valid_number( provider_price ) ) {
			noty_alert('warning', 'Debe ingresar monto válido')
			return false
		}
		if ( isNaN( provider_iva ) ) {
			noty_alert('warning', 'Debe seleccionar el IVA')
			return false
		}

    if ( this.exist(list_id) ) {
      noty_alert('info', 'Este interviniente ya se encuentra agregado con la misma función.')
      return false
    }
		return true
	},
  update_table(selector_id, type_total){
		// actualizamos el valor en la tabla
		const table_body = document.querySelector(`#${selector_id}`)
		table_body.innerHTML = ''
		const providers = this.list.filter( element => element.type_total == type_total )
		for (let i = 0; i < providers.length; i++){
			let provider = providers[i]
        const td_provider_porcent = (type_total == 'subtotal' ) ? `<td>${provider.provider_price}%</td>` : ''
				table_body.innerHTML += `
					<tr id="${provider.list_id}">
						<td>${provider.name}</td>
						<td>${provider.role_name}</td>
            ${td_provider_porcent}
						<td>$${numberFormat.format(provider.provider_price_calculate)}</td>
						<td>${provider.provider_iva}%</td>
						<td>$${ numberFormat.format(provider.value_iva) }</td>
						<td> <b>$${ numberFormat.format(provider.total ) }</b> </td>
						<td id="porcentaje_representa_${provider.provider_id}"> ${provider.provider_porcent}% </td>
						<td><button type="button" class="btn u-btn-red remove-provider" onclick="project_providers.remove('${provider.list_id}')" 
						title="Quitar interviniente"> <i class="fa fa-trash"></i> </button></td>
					</tr>
				`
		}
		if(providers.length > 0){
      const colspan = ( type_total == 'price' ) ? 2 : 3
			table_body.innerHTML += `
				<tr class="g-bg-cyan-opacity-0_1">
					<td colspan='${colspan}'><strong>Totales:</strong></td>
					<td> $${ numberFormat.format( roundToTwo(providers.reduce( (acc, provider) => acc + provider.provider_price_calculate, 0 )) ) } </td>
					<td></td>
					<td>$${ numberFormat.format( roundToTwo(providers.reduce( (acc, provider) => acc + provider.value_iva, 0 )) ) }</td>
					<td> $${ numberFormat.format( roundToTwo(providers.reduce( (acc, provider) => acc + provider.total, 0 )) ) } </td>
					<td colspan='2'></td>
				</tr>
			`
		} else {
      const colspan = ( type_total == 'price' ) ? 8 : 9
      table_body.innerHTML = `
        <tr> <td colspan='${colspan}'  class='text-center'> No se ha agregado ningun proveedor. </td> </tr>
      `
    }
	},
  update_tables(){
    this.update_table('provider-list', 'price')
    this.update_table('other-provider-list', 'subtotal')
  },
  remove( list_id ) {
		event.preventDefault()
		this.list = this.list.filter( p => p.list_id != list_id )
		document.getElementById(list_id).remove()
		project.calculate_subtotal()
	},
  exist(list_id){
		// we check that this provider doesn't exit in provider_list with same rol and type
		// one provider can be in array more the one time with different rol
		let provider_find = this.list.find( element => element.list_id == list_id )
		return provider_find !== undefined
	},
  calculate_price({payment_method_id,provider_price}){
		if (payment_method_id == 2) { // porcent
			const porcent = provider_price/100
			return roundToTwo(project.subtotal * porcent)
		} else { // valor fijo
			return roundToTwo(provider_price)
		}
	},
  calcular_porcentaje_representa(){
		if ( valid_number(project.final_price) ) {
			for (let i = 0; i < this.list.length; i++){
				if (this.list[i].type_total == 'price') {
					this.list[i].provider_porcent = roundToTwo( ( this.list[i].total * 100 ) / project.subtotal )
				} else {
					this.list[i].provider_porcent = roundToTwo( ( this.list[i].total * 100 ) / project.final_price )
				}
			}
		} else {

			console.info('El proyecto no tiene valor. Fn calcular_porcentaje_representa')
			return 'Valor de proyecto invalido'
		}
	},
	represent_final_porcent({provider_id}){
		// return total value to a providers and his porcent
		const provider = this.list.filter( element => element.provider_id == provider_id)
		const total_value = roundToTwo( provider.reduce( (accumulator, currentValue) => accumulator + currentValue.total, 0 ) )
		const porcent = roundToTwo( ( total_value * 100 ) / project.final_price )
		return { total: total_value, porcent: porcent }
	},
  calculate_value_iva({provider_iva, provider_price_calculate}) {
		return roundToTwo(( provider_iva * provider_price_calculate ) / 100)
	},
  add_to_form(){
		for (let i = 0; i < this.list.length; i++){
			project.form.append( `project[project_providers_attributes][${i}][provider_id]` , this.list[i].provider_id)
			project.form.append( `project[project_providers_attributes][${i}][provider_role_id]` , this.list[i].provider_role)
			project.form.append( `project[project_providers_attributes][${i}][payment_method_id]` , this.list[i].payment_method_id)
			project.form.append( `project[project_providers_attributes][${i}][price]` , this.list[i].provider_price)
			project.form.append( `project[project_providers_attributes][${i}][iva]` , this.list[i].provider_iva)
			project.form.append( `project[project_providers_attributes][${i}][value_iva]` , this.list[i].value_iva)
			project.form.append( `project[project_providers_attributes][${i}][price_calculate]` , this.list[i].provider_price_calculate)
			project.form.append( `project[project_providers_attributes][${i}][porcent]` , this.list[i].provider_porcent)
			project.form.append( `project[project_providers_attributes][${i}][type_total]` , this.list[i].type_total)
		}
	},
  update_value_of_others_providers(){
		this.list.forEach( provider => {
			if (provider.type_total == 'subtotal') {
				provider.provider_price_calculate = this.calculate_price( provider )
				provider.value_iva = this.calculate_value_iva(provider)
				provider.total = roundToTwo(provider.value_iva + provider.provider_price_calculate)
			}
		});
	},
}