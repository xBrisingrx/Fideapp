let sale_field_table, all_fields

let sale = {
  precio: null,
  resto: null,
  cuotas: null,
  valor_cuota: null,
  cant_payments: 0,
  cant_payment_files:0,
  currencies: '',
  form: '',
  entrega: 0,
  client_index: 0,
  suma_cuotas_manual: 0,
  select_payment_types: '',
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
    const nodo = event.target.parentElement.parentElement
    const selected = select.options[select.selectedIndex]
    const tomado_en = nodo.querySelector('#exchange_value')
    const calculo_en_pesos = nodo.querySelector('#calculo_en_pesos')

    if (selected.dataset.exchange == 'true') {
      tomado_en.value = ''
      tomado_en.placeholder = `1 ${selected.dataset.currency} en $`
    } else {
      tomado_en.value = 1
    }
    tomado_en.classList.toggle( 'd-none', !(selected.dataset.exchange == 'true') )
    calculo_en_pesos.classList.toggle( 'd-none', !(selected.dataset.exchange == 'true') )
    if ( valid_number(parseFloat(tomado_en.value)) || valid_number( parseFloat(nodo.querySelector(`#payment`).value) ) ) {
      calc_valor_en_pesos(event.target)
    }
    this.calcular_monto_pagado()
  },
  calc_valor_en_pesos(object){
    const fee_payment_value = string_to_float_with_value(document.getElementById(`${object}payment`).value)
    const exchange_value = string_to_float_with_value(document.getElementById(`${object}value_in_pesos`).value)
    const calculo_en_pesos = document.getElementById(`${object}calculo_en_pesos`)

    if ( !valid_number(exchange_value) || !valid_number(fee_payment_value) ) {
      calculo_en_pesos.value = 0
      return
    }
    calculo_en_pesos.value = fee_payment_value*exchange_value
  },
  calcular_monto_pagado(){
    $('#valor_restante').html('')
    // seleccionamos los pagos
    const payments = document.getElementsByClassName('payment-data')
    sale.entrega = 0
    // recorremos y sumamos las entregas
    for (let pay of payments) {
      const payed = string_to_float_with_value( pay.querySelector('#calculo_en_pesos').value )
      if (valid_number(payed)) {
        sale.entrega += payed
      }
    }

    if (isNaN(sale.entrega)) {
      sale.resto = sale.precio
    } else {
      sale.resto = sale.precio - sale.entrega
    }

    if (sale.entrega > 0 &&  !isNaN(sale.entrega) && sale.entrega <= sale.precio) {
      $('#valor_restante').append(`A pagar en cuotas: <b>$${sale.resto}</b>`)
      calular_valor_cuota()
    } else if ( sale.entrega > sale.precio ) {
      $('#valor_restante').append(`A pagar en cuotas: <b>0</b>`)
      // $('#valor_restante').append(`<p class='text-danger ml-4'> Ingreso un valor mayor al del lote </>`)
    }
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
