let urbanizations_table

function modal_disable_urbanization(id) {
  $('#modal-disable-urbanization #urbanization_id').val(id)
  $('#modal-disable-urbanization').modal('show')
}

$(document).ready(function(){
	urbanization_table = $("#urbanizations_table").DataTable({
    'ajax':'urbanizations',
    'columns': [
    {'data': 'name'},
    {'data': 'actions'}
    ],
    'language': {'url': datatables_lang}
	})

  $("#form-disable-urbanization").on("ajax:success", function(event) {
    urbanization_table.ajax.reload(null,false)
    let msj = JSON.parse(event.detail[2].response)
    noty_alert(msj.status, msj.msg)
    $("#modal-disable-urbanization").modal('hide')
  }).on("ajax:error", function(event) {
    let msj = JSON.parse( event.detail[2].response )
    $.each( msj, function( key, value ) {
      $(`#form-urbanization #urbanization_${key}`).addClass('is-invalid')
      $(`#form-urbanization .urbanization_${key}`).text( value ).show('slow')
    })
  })
})

