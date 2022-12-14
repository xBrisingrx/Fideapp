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
