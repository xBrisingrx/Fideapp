let lands_table

function modal_disable_land(id) {
  $('#modal-disable-land #land_id').val(id)
  $('#modal-disable-land').modal('show')
}

$(document).ready(function(){
	lands_table = $("#lands_table").DataTable({
    'ajax':`lands`,
    'columns': [
    {'data': 'code'},
    {'data': 'area'},
    {'data': 'ubication'},
    {'data': 'price'},
    {'data': 'is_green_space'},
    {'data': 'is_corner'},
    {'data': 'status'},
    {'data': 'bought_date'},
    {'data': 'blueprint'},
    {'data': 'actions'}
    ],
    'language': { 'url': datatables_lang }
	})

  $("#form-disable-land").on("ajax:success", function(event) {
    lands_table.ajax.reload(null,false)
    let msg = JSON.parse(event.detail[2].response)
    noty_alert(msg.status, msg.msg)
    $("#modal-disable-land").modal('hide')
  }).on("ajax:error", function(event) {
    let msg = JSON.parse( event.detail[2].response )
    console.log(event.detail[2].response)
    $.each( msg, function( key, value ) {
      $(`#form-land #land_${key}`).addClass('is-invalid')
      $(`#form-land .land_${key}`).text( value ).show('slow')
    })
  })
})