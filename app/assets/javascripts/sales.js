let sale_field_table, all_fields

let sale = {
  precio: null,
  resto: null,
  cuotas: null,
  valor_cuota: null,
  date: '',
  due_day: null,
  cant_payments: 0,
  cant_payment_files:0,
  currencies: '',
  form: '',
  entrega: 0,
  client_index: 0,
  suma_cuotas_manual: 0,
  select_payment_types: '',
  reset(){
    this.precio = null
    this.resto = null
    this.cuotas = null
    this.valor_cuota = null
    this.cant_payments = 0
    this.cant_payment_files = 0
    this.currencies =  ''
    this.form =  ''
    this.entrega =  0
    this.client_index =  0
    this.suma_cuotas_manual =  0
    this.select_payment_types =  ''
    this.date = ''
    this.due_day = null
  },
  update_number_of_payments(event){
    const valor_valido = valid_number( parseInt(event.target.value) )
    if( valor_valido ){
      this.cuotas = event.target.value
      this.calcular_valor_cuota()
      this.generate_fees()
    } else {
      noty_alert('info', 'Ingreso un valor no válido')
    }
    event.target.classList.toggle('is-invalid', !valor_valido)
  },
  update_due_day(event){
    if(this.date == '') {
      return
    }
    const due_day = parseInt(event.target.value)
    const date = new Date(`${this.date}T00:00:00`)
    const last_day_of_month = new Date( date.getYear(),date.getMonth(), 0 )
    if( valid_number(due_day) && due_day <= last_day_of_month.getDate() ) {
      this.due_day = due_day
      date.setDate(due_day)
      document.querySelector('.date').value = date_to_string(date)
      this.date = date_to_string(date)
    } else {
      noty_alert('info', 'Valor invalido')
      return
    }
  },
  update_date(event){
    const date = event.target.value
    if(date != ''){
      this.date = new Date(`${date}T00:00:00`)
      this.due_day = this.date.getDate()
      document.querySelector('.due_day').value = this.due_day
      if ( !document.getElementById('setear_cuotas').checked  ) {
        this.generate_fees()
      }
    }
  },
  update_pagado_en_cuotas(){
    const total_pagado_en_cuotas = this.suma_cuotas_sale_land()
    document.getElementById('total_pagado_en_cuotas').value = `${string_to_currency( float_to_string( total_pagado_en_cuotas ) )}`
  },
  set_cuotas(cantidad_cuotas, nodo_id){
    cantidad_cuotas++
    for (let i = 1; i < cantidad_cuotas; i++) {
       $(`#${nodo_id}`).append(`
        <div class="form-group row">
          <label class="col-3">Cuota #${i}</label>
          <input id="cuota_n_${i}" type="number" value="" required placeholder="Ingresar valor de la cuota..." class="form-control rounded-0 col-3 cuota_n"></input>
        </div>
      `)
    }
  },
  modal_destroy( sale_id, apple, land = '' ) {
    document.querySelector('#modal-destroy-sale #modal-title').innerHTML = `Manzana <b>${apple}</b> - Lote <b>${land}</b>`
    document.querySelector('#form-destroy-sale #sale_id').value = sale_id
    $('#modal-destroy-sale').modal('show')
  },
  destroy(){
    const sale_id = document.querySelector('#form-destroy-sale #sale_id').value
    fetch(`/sales/${sale_id}`, {
      method: 'DELETE',
      headers: {           
          'X-CSRF-Token': document.getElementsByName('csrf-token')[0].content,
      }
    })
    .then( response => response.json() )
    .then( response => {
      noty_alert(response.status, response.msg)
      lands_table.ajax.reload(null,false)
      document.querySelector('#form-destroy-sale #sale_id').value = ''
      $('#modal-destroy-sale').modal('hide')
    } )
    .catch( error => noty_alert('error', 'Ocurrio un error, no se pudo registrar la venta') )
  },
  modal_reset_payments(sale_id){
    document.querySelector('#form-reset-payments #sale_id').value = sale_id
    $('#modal-reset-payments').modal('show')
  },
  reset_payments(){
    const sale_id = document.querySelector('#form-reset-payments #sale_id').value
    fetch(`/sales/reset_payments/${sale_id}`, {
      method: 'POST',
      headers: {           
          'X-CSRF-Token': document.getElementsByName('csrf-token')[0].content,
      }
    })
    .then( response => response.json() )
    .then( response => {
      location.reload()
    } )
    .catch( error => noty_alert('error', 'Ocurrio un error, no se pudo registrar la venta') )
  },
  set_exchange(event){
    const select = event.target
    const selected = select.options[select.selectedIndex]
    const need_exchange = selected.dataset.exchange == 'true'
    const nodo = select.parentElement.parentElement
    const tomado_en = nodo.querySelector('#exchange_value')
    const calculo_en_pesos = nodo.querySelector('#value_in_pesos')

    if (need_exchange) {
      tomado_en.value = ''
      tomado_en.placeholder = `1 ${selected.dataset.currency} en $`
    } else {
      tomado_en.value = 1
    }
    tomado_en.classList.toggle( 'd-none', !(need_exchange) )
    calculo_en_pesos.classList.toggle( 'd-none', !(need_exchange) )
    if ( valid_number(parseFloat(tomado_en.value)) || valid_number( parseFloat(nodo.querySelector(`#payment`).value) ) ) {
      this.calcular_monto_en_pesos(nodo)
    }
    this.calcular_monto_pagado()
  },
  actualizar_monto_en_pesos(event){
    const element = event.target.parentElement.parentElement
    this.calcular_monto_en_pesos(element)
  },
  calcular_monto_en_pesos(element){ // se calcula el valor en pesos del ingreso
    const calculo_en_pesos = element.querySelector(`#value_in_pesos`)
    const fee_payment_value = string_to_float_with_value(element.querySelector('#payment').value)
    const exchange_value = string_to_float_with_value(element.querySelector('#exchange_value').value)
    if ( !valid_number(exchange_value) || !valid_number(fee_payment_value) ) {
      calculo_en_pesos.value = 0
      return
    }
    const calculo = `${fee_payment_value*exchange_value}`
    calculo_en_pesos.value = string_to_currency(calculo)
    this.calcular_monto_pagado()
  },
  calcular_monto_pagado(){
    const valor_restante = document.getElementById('valor_restante')
    valor_restante.innerHTML = ''
    // seleccionamos los pagos
    const payments = document.getElementsByClassName('payment-data')
    this.entrega = 0
    // recorremos y sumamos las entregas
    for (let pay of payments) {
      const payed = string_to_float_with_value( pay.querySelector('#value_in_pesos').value )
      if (valid_number(payed)) {
        this.entrega += payed
      }
    }

    if (isNaN(this.entrega)) {
      this.resto = roundToTwo(this.precio)
    } else {
      this.resto = roundToTwo(this.precio - this.entrega)
    }

    if (valid_number(this.entrega) && this.entrega <= this.precio) {
      const resto = `${this.resto}`
      valor_restante.innerHTML = `A pagar en cuotas: <b>${string_to_currency(resto)}</b>`
      this.calcular_valor_cuota()
    } else if ( this.entrega > this.precio ) {
      valor_restante.innerHTML = `A pagar en cuotas: <b>0</b>`
    }
  },
  set_fee_start_date(event){
    let first_pay_date = new Date(`${event.target.value}T00:00:00`)
    first_pay_date.setMonth( first_pay_date.getMonth() + 1 )

    if(valid_number( parseInt( this.due_day ) )) {
      first_pay_date.setDate( this.due_day)
    }
    document.getElementById('sale_fee_start_date').value = date_to_string( first_pay_date )
    this.date = date_to_string( first_pay_date )
    if ( !document.getElementById('setear_cuotas').checked  ) {
      this.generate_fees()
    }
  },
  calcular_valor_cuota() {
    if( !valid_number(this.cuotas) ) {
      return
    }
    this.valor_cuota = roundToTwo( this.resto/this.cuotas )
  },
  generate_fees(){
    if (!valid_number(this.valor_cuota) && !valid_number(this.cuotas) ) {
      // noty_alert('info', "Debe ingresar el valor del lote")
      // addClassInvalid( document.getElementById('price') )
      console.info(this.valor_cuota, this.cuotas)
      return
    }

    const fee_value = string_to_currency(float_to_string(this.valor_cuota))
    const fee_start_date = document.querySelector(".date").value
    let html_to_insert = ''
    if (this.cuotas > 0 && this.due_day > 0 && fee_start_date != '') {
      let fee_date =  new Date(`${fee_start_date}T00:00:00`)
      fee_date.setDate( this.due_day )
      for (let i = 1; i <= this.cuotas; i++) {
        html_to_insert += `
          <div class='row col-12 my-2 fee_added' >
            <label class='col-4 col-md-2'> Cuota #${i} </label>
            <input id='fee_value' type='text' 
              data-type='currency' 
              data-number='${i}' 
              value='${fee_value}'
              class='form-control rounded-0 col-4 col-md-2 fee_value_input'
              onchange='sale.update_pagado_en_cuotas()'
              disabled>
            <label class='col-4 col-md-1'> Fecha:  </label>
            <input id='fee_date' type='date' value='${date_to_string(fee_date)}' class='form-control rounded-0 col-4 col-md-2' disabled >
          </div>
          `	
        fee_date.setMonth( fee_date.getMonth() + 1 )
      } // end for
    } // end if
    document.getElementById('fees_list').innerHTML = html_to_insert
    set_currency_fn()
    this.update_pagado_en_cuotas()
  },
  remove_payment(event){
    event.preventDefault()
    event.target.parentElement.remove()
    this.cant_payments--
    this.calcular_monto_pagado()
  },
  set_fees_manual(event){
    const is_check = event.target.checked
    const fees = document.getElementsByClassName('fee_added')
    if(fees.length == 0){
      e.target.checked = false
      return
    }
    for( let fee of fees ) {
      fee.querySelector('#fee_value').disabled = !is_check
      fee.querySelector('#fee_date').disabled = !is_check
    }
    document.querySelector('.number_of_payments').disabled = is_check
    document.querySelector('.due_day').disabled = is_check
    document.querySelector('.fee_start_date').disabled = is_check
  },
  add_paymentos_to_form() {
    const payments = document.getElementsByClassName('payment-data')
    let i = 0
    for (let pay of payments) {
      let paid = string_to_float_with_value( pay.querySelector('#payment').value )
      if ( !valid_number(paid) ) {
        pay.querySelector('#payment').parentElement.classList.add('u-has-error-v1')
        return
      }
      i++
      pay.querySelector('#payment').parentElement.classList.remove('u-has-error-v1')
      const currency_selected = pay.querySelector('#payment_currency').options[pay.querySelector('#payment_currency').selectedIndex]
      const payment_currency_id = parseInt( currency_selected.value ) 
      if (payment_currency_id == 0 ) {
        pay.querySelector('#payment_currency').parentElement.classList.add('u-has-error-v1')
        return
      }
      pay.querySelector('#payment_currency').parentElement.classList.remove('u-has-error-v1')
      const exchange_value = string_to_float_with_value( pay.querySelector('#exchange_value').value )
      const valor_en_pesos = string_to_float_with_value( pay.querySelector('#value_in_pesos').value )
      const date = (pay.querySelector('#pay_date').value != '') 
        ? pay.querySelector('#pay_date').value 
        : document.getElementById('sale_date').value 
      if ( currency_selected.dataset.exchange == 'true' && !valid_number(exchange_value) ) {
        noty_alert('error','Debe ingresar en cuanto toma la moneda ingresada')
        pay.querySelector('#exchange_value').classList.add('u-has-error-v1')
        return
      }
  
      if ( !valid_number(valor_en_pesos) ) {
        return
      }
      this.form.append( `sale[payments_attributes][${i}][payments_currency_id]`, payment_currency_id)
      this.form.append( `sale[payments_attributes][${i}][payment]`, paid)
      this.form.append( `sale[payments_attributes][${i}][taken_in]`, exchange_value)
      this.form.append( `sale[payments_attributes][${i}][comment]`, pay.querySelector('#payment_comment').value)
      this.form.append( `sale[payments_attributes][${i}][date]`, date)
      this.form.append( `sale[payments_attributes][${i}][first_pay]`, true)
      
      let files = pay.querySelector('#fileAttachment')
      if (files !== null) {
        let totalFiles = files.files.length
        if (totalFiles > 0) {
          for (let n = 0; n < totalFiles; n++) {
            this.form.append( `sale[payments_attributes][${i}][files][]`, files.files[n])
          }
        }
      }
    }
  },
  add_fees_to_form(){
    const fees = document.getElementsByClassName('fee_added')
    if(fees.length == 0){
      noty_alert('warn', 'No se ha generado cuotas')
      return
    }
    for (let index = 0; index < fees.length; index++) {
      const fee = fees[index];
      const fee_value =  string_to_float_with_value(fee.querySelector('#fee_value').value)
      const fee_date = fee.querySelector('#fee_date').value
      const fee_number = fee.querySelector('#fee_value').dataset.number
      this.form.append( `sale[fees_attributes][${index}][number]`, fee_number)
      this.form.append( `sale[fees_attributes][${index}][value]`, fee_value)
      this.form.append( `sale[fees_attributes][${index}][due_date]`, fee_date)
    }
  },
  suma_cuotas_sale_land(){
    const cuotas = document.getElementsByClassName('fee_value_input')
    const total = Array.from(cuotas).reduce( (acum, element) => acum + string_to_float_with_value(element.value), 0 )
    return roundToTwo(total)
  }
}

function modal_disable_sale_field(id) {
  $('#modal-disable-sale_field #field_id').val(id)
  $('#modal-disable-sale_field').modal('show')
}

function modal_sales( id ) {
  fetch(`/pay_sale/${id}`)
    .then( response => response.json() )
    .then( response => {
      $('#form-field-pay-quote #id').val(response.data.id)
      $('#form-field-pay-quote #aply-interest-text').html(`aplicar interes del ${response.interest}%`)
      $('#form-field-pay-quote #valor_cuota').html( `Valor cuota: $ <b> ${response.data.money} </b>` )
    })
  $('#modal-sales').modal('show')
}

function pagar_cuota() {
  
}

$(document).ready(function(){
	sale_field_table = $("#sale_field_table").DataTable({ 'language': {'url': "/assets/plugins/datatables_lang_spa.json"} })
  all_fields = $("#all_lands").DataTable({
    'language': {'url': "/assets/plugins/datatables_lang_spa.json"}
  })
})
