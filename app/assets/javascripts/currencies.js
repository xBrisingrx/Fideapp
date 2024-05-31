let currencies_table

function modal_disable_currency(id) {
  $('#modal-disable-currency #currency_id').val(id)
  $('#modal-disable-currency').modal('show')
}

$(document).ready(function(){
	

  $("#form-disable-currency").on("ajax:success", function(event) {
    currencies_table.ajax.reload(null,false)
    let msg = JSON.parse(event.detail[2].response)
    noty_alert(msg.status, msg.msg)
    $("#modal-disable-currency").modal('hide')
  }).on("ajax:error", function(event) {
    let msg = JSON.parse( event.detail[2].response )
    $.each( msg, function( key, value ) {
      $(`#form-currency #currency_${key}`).addClass('is-invalid')
      $(`#form-currency .currency_${key}`).text( value ).show('slow')
    })
  })
})