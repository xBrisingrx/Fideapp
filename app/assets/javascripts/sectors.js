let sectors_table

function modal_disable_sector(id) {
  $('#modal-disable-sector #sector_id').val(id)
  $('#modal-disable-sector').modal('show')
}

$(document).ready(function(){
	sector_table = $("#sectors_table").DataTable({
    'ajax':'sectors',
    'columns': [
    {'data': 'name'},
    {'data': 'urbanization'},
    {'data': 'actions'}
    ],
    'language': {'url': "/assets/plugins/datatables_lang_spa.json"}
	})

  $("#form-disable-sector").on("ajax:success", function(event) {
    sector_table.ajax.reload(null,false)
    let msj = JSON.parse(event.detail[2].response)
    noty_alert(msj.status, msj.msg)
    $("#modal-disable-sector").modal('hide')
  }).on("ajax:error", function(event) {
    let msj = JSON.parse( event.detail[2].response )
    console.log(event.detail[2].response)
    $.each( msj, function( key, value ) {
      $(`#form-sector #sector_${key}`).addClass('is-invalid')
      $(`#form-sector .sector_${key}`).text( value ).show('slow')
    })
  })
})