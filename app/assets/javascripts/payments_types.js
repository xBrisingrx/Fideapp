let payments_types_table

function payment_type(id) {
  $('#modal-disable-payment_type #payment_type_id').val(id)
  $('#modal-disable-payment_type').modal('show')
}

$(document).ready(function(){
	payments_types_table = $("#payments_types_table").DataTable({
    'ajax':'payments_types',
    'columns': [
    {'data': 'name'},
    {'data': 'currencies'},
    {'data': 'actions'}
    ],
    'language': {'url': "/assets/plugins/datatables_lang_spa.json"}
	})

  $("#form-disable-payment_type").on("ajax:success", function(event) {
    payment_type_table.ajax.reload(null,false)
    let msj = JSON.parse(event.detail[2].response)
    noty_alert(msj.status, msj.msg)
    $("#modal-disable-payment_type").modal('hide')
  }).on("ajax:error", function(event) {
    let msj = JSON.parse( event.detail[2].response )
    console.log(event.detail[2].response)
    $.each( msj, function( key, value ) {
      $(`#form-payment_type #payment_type_${key}`).addClass('is-invalid')
      $(`#form-payment_type .payment_type_${key}`).text( value ).show('slow')
    })
  })
})