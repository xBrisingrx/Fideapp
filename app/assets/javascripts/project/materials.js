const project_materials = {
  list: [],
  add(event){
    event.preventDefault()
    const material = {
      id: parseInt(document.getElementById('project_material_id').value),
      name: $('#project_material_id option:selected').text(),
      type_units: document.getElementById('type_unit').value,
      units: parseInt( document.getElementById('material_units').value ),
      price: string_to_float( 'material_price' )
    }

    if (material.id == null || material.id == '') {
      noty_alert('error', 'Error al agregar el material a la lista')
      return
    }
    if ( material.units == null || isNaN(material.units)) {
      noty_alert('error', 'Las unidades deben ser un numero')
      return
    }
    if ( !valid_number(material.price) ) {
      noty_alert('error', 'El precio debe ser un numero')
      return 
    }
    this.list.push( material )
    this.update_materials_table()
    $('#project_material_id option:selected').attr('disabled', 'disabled')
    $('.select-2-project-material').val('Ninguna').trigger('change')
    $('.select-2-project-material-unit').val('').trigger('change')
    document.getElementById('material_units').value = ''
    document.getElementById('material_price').value = ''
    project.calculate_subtotal()
  },
  remove(event, material_id){
    event.preventDefault()
    $(`#project_material_id option[value='${material_id}']`).attr('disabled', false)
    this.list = this.list.filter( m => m.id != material_id )
    this.update_materials_table()
    project.calculate_subtotal()
  },
  update_materials_table(){
    const table_body = document.getElementById('material-list')
    table_body.innerHTML = ''
    for (let i = 0; i < this.list.length; i++) {
      const material = this.list[i]
      table_body.innerHTML += `
        <tr id="row-${material.id}">
          <td>${material.name}</td>
          <td>${material.type_units}</td>
          <td>${material.units}</td>
          <td>$${numberFormat.format(material.price)}</td>
          <td><b>$${numberFormat.format( roundToTwo(material.price * material.units) )}</b></td>
          <td><button type="button" class="btn u-btn-red remove-material" onclick="project_materials.remove(event, ${material.id})" 
            title="Quitar material"> <i class="fa fa-trash"></i> </button></td>
        </tr>
      `
    }
    table_body.innerHTML += `
      <tr class="g-bg-cyan-opacity-0_1">
        <td><strong>Totales:</strong></td>
        <td></td>
        <td></td>
        <td></td>
        <td>$${ numberFormat.format( roundToTwo(this.list.reduce( (acc, material) => acc + (material.price * material.units), 0 )) ) }</td>
        <td></td>
      </tr>
    `
    table_body.parentElement.classList.toggle('d-none', this.list.length == 0)
  },
  sum_price(){
    return roundToTwo( this.list.reduce( (acc, element) => acc + (element.price * element.units), 0 ) )
  },
  material_porcent(){
    const price_materials = this.sum_price()
    return roundToTwo(( price_materials * 100 ) / project.final_price )
  },
  add_to_form(){
		for (let i = 0; i < this.list.length; i++){
			project.form.append( `project[project_materials_attributes][${i}][material_id]` , this.list[i].id)
			project.form.append( `project[project_materials_attributes][${i}][type_units]` , this.list[i].type_units)
			project.form.append( `project[project_materials_attributes][${i}][units]` , this.list[i].units)
			project.form.append( `project[project_materials_attributes][${i}][price]` , this.list[i].price)
		}
	},
}