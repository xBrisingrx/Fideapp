const project_apples = {
  sectors:[],
	apples:[],
  apple_has_corner: false,
  charge_sectors(){
		const urbanization_id = document.getElementById("project_urbanization_id").value
		fetch(`/sectors/filter_for_urbanization/${urbanization_id}.json`).then( response => response.json() )
			.then( r => {
				const sector_list = document.querySelector('#sector_list')
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
	charge_apples(){ // charge apples to modal
		const modal_body = document.getElementById("list_of_apples")
		const btn_show_apple_list = document.getElementById("show_apple_list")
		const sector_id = this.sectors.filter( sector => sector.id == document.getElementById('sector_list').value )[0].id

		modal_body.innerHTML = ''
		fetch(`/apples/filter_for_sector/${sector_id}.json`).then( response => response.json() ).then( r => {
			document.getElementById("select_all_apples").checked = true
			if (r.data.length > 0) {
				btn_show_apple_list.disabled = false;
				for (let index = 0; index < r.data.length; index++) {
					const element = r.data[index];
					if ( element.lands === 0 ) { continue }

					modal_body.innerHTML += `
					<div class="col-3">
						<div class="form-group g-mb-10 g-mb-0--md">
							<label class="u-check g-pl-25">
								<input class="g-hidden-xs-up g-pos-abs g-top-0 g-left-0 apple-added" type="checkbox" checked data-apple-id=${element.id} data-apple-code="${element.code}">
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
				btn_show_apple_list.disabled = true;
			}
		})
	},
  remove_apple(apple_id){
		document.getElementById(`apple-${apple_id}`).remove()
	},
	check_all() {		
		let apples_added = document.getElementsByClassName("apple-added")
		for (let checkbox in apples_added) {
      apples_added.classList.toggle('selected', event.target.checked)
			apples_added[checkbox].checked = event.target.checked
		}
	},
	verify_is_check(event, class_name){ // add or remove a class depend if checkbox is checked
		const land_input = event.target.parentElement.querySelector('.land')
		land_input.classList.toggle(class_name, event.target.checked)
		this.calculate_price_land()
	},
	select_all_lands(event){
		const checkbox = event.target
		const checkbox_lands = checkbox.parentElement.parentElement.parentElement.querySelectorAll('.land')
		for (let index = 0; index < checkbox_lands.length; index++) {
			checkbox_lands[index].checked = checkbox.checked;
			checkbox_lands[index].classList.toggle('land-selected', checkbox.checked)
		}
		project_apples.calculate_price_land()
	},
	calculate_price_land(){
		this.update_lands_to_arrays() // actualizo mis arrays de lotes

		const lands = document.getElementsByClassName("land")
		if (lands.length == 0) {
			return
		}
		const selected_lands = Array.from(lands).filter( element => element.checked ).length
		const land_price = roundToTwo(project.final_price/selected_lands)
		const land_price_to_string = float_to_string( land_price )
		
		document.getElementById('project_land_price').value = land_price_to_string
		document.getElementById('project_land_corner_price').value = land_price_to_string
		formatCurrency( $('#project_land_price') )
		formatCurrency( $('#project_land_corner_price') )
	},
	update_lands_to_arrays(){ // actualizo los lotes tildados a mis arrays de lotes
		const lands_list = document.getElementsByClassName('land')
		for (let index = 0; index < lands_list.length; index++) {
			if ( lands_list[index].checked ) {
				( lands_list[index].dataset.corner === 'Si' ) ? project.lands_corner.push( lands_list[index].dataset.landId ) : project.lands.push( lands_list[index].dataset.landId )
			}
		}
	},
	add_apples_to_form(){
		const apples = document.getElementsByClassName("apples-adds")
		for (let i = 0; i < apples.length; i++) {
			project.form.append( `project[apple_projects_attributes][${i}][apple_id]` , apples[i].value)
		}
	},
	add_lands_to_form(){
		const lands = document.getElementsByClassName("land-selected")
		for (let i = 0; i < lands.length; i++) {
			const land_price = ( lands[i].dataset.corner === 'Si' ) ? project.form.get('project[land_corner_price]') : project.form.get('project[land_price]')
			project.form.append( `project[land_projects_attributes][${i}][land_id]` , lands[i].dataset.landId)
			project.form.append( `project[land_projects_attributes][${i}][price]` , land_price)
			project.form.append( `project[land_projects_attributes][${i}][price_quotas]` , land_price )
			project.form.append( `project[land_projects_attributes][${i}][price_quotas_corner]` , land_price )
			project.form.append(`project[land_projects_attributes][${i}][finalized]`, document.getElementById('project_finalized').checked )
		}
	},
}

async function async_add_apples(){ // adds apples and lands to form
	document.getElementById('accordion-lands').innerHTML = ''
	const apples = document.getElementsByClassName("apple-added")

	if ( document.querySelectorAll("#modal_apple_list input[type='checkbox']:checked").length == 0) {
		noty_alert("info", "No hay manzanas para agregar")
		return
	}
	project_apples.apples = []
	project_apples.lands = []
	project_apples.lands_corner = []
	let land_list = '<div class="row">'
	for (let apple in  apples ) {
		if (apples[apple].checked) {
			const apple_id = apples[apple].dataset.appleId
			project_apples.apples.push(apple_id)
			const response = await fetch(`/apples/${apple_id}/lands.json`)
			const data = await response.json()
			land_list += `
			<div class="form-group col-12">
				<label class="form-check-inline u-check g-pl-25">
					<input class="g-hidden-xs-up g-pos-abs g-top-0 g-left-0" type="checkbox" value="1" checked onclick="project_apples.select_all_lands(event)" />
					<div class="u-check-icon-checkbox-v6 g-absolute-centered--y g-left-0">
						<i class="fa" data-check-icon="&#xf00c"></i>
					</div>
					Seleccionar todos
				</label>
			</div>
			`
			data.data.forEach( land => {
				(land.is_corner === 'Si') ? project_apples.lands_corner.push( land.id ) : project_apples.lands.push( land.id )

				land_list += `<div class="form-group col-3">
			    <label class="form-check-inline u-check g-pl-25">
			      <input class="land land-selected g-hidden-xs-up g-pos-abs g-top-0 g-left-0" type="checkbox" data-land-id="${land.id}" data-corner=${land.is_corner} value="1" 
							checked name="project[land_${land.id}]" id="project_land_${land.id}" onclick="project_apples.verify_is_check(event, 'land-selected')" />
			      <div class="u-check-icon-checkbox-v6 g-absolute-centered--y g-left-0">
			        <i class="fa" data-check-icon="&#xf00c"></i>
			      </div>
			      ${ (land.is_corner === 'Si') ? land.code + ' (Esquina)' : land.code }
			    </label>
			  </div>`
			} )
			land_list += "</div>"
			$('#accordion-lands').append(`
				<div class="card g-brd-none rounded-0 g-mb-15">
					<div id="accordion-lands-heading-${apple_id}" class="u-accordion__header g-pa-0" role="tab">
						<h5 class="mb-0">
							<a class="d-flex g-color-main g-text-underline--none--hover g-brd-around g-brd-gray-light-v4 g-rounded-5 g-pa-10-15" 
							href="#accordion-lands-body-${apple_id}" aria-expanded='false'
							aria-controls="accordion-lands-body-${apple_id}" 
							data-toggle="collapse" 
							data-parent="#accordion-lands">
								<span class="u-accordion__control-icon g-mr-10">
									<i class="fa fa-angle-down"></i>
									<i class="fa fa-angle-up"></i>
								</span>
								${apples[apple].dataset.appleCode}
							</a>
						</h5>
					</div>
					<div id="accordion-lands-body-${apple_id}" class="collapse" role="tabpanel" aria-labelledby="accordion-lands-heading-${apple_id}" 
							data-parent="#accordion-lands">
						<input class="apples-adds" type="hidden" value="${apple_id}" />
						<div class="u-accordion__body g-color-gray-dark-v5">
							${land_list}
						</div>
					</div>
				</div>
					`)
				land_list = '<div class="row">'
		 }
		 project_apples.calculate_price_land()
	} // for apple in apples
}