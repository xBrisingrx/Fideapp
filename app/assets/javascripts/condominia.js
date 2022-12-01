let condominia_table

function modal_disable_condominium(id) {
  $('#modal-disable-condominium #condominium_id').val(id)
  $('#modal-disable-condominium').modal('show')
}

$(document).ready(function(){
	condominia_table = $("#condominia-table").DataTable({
    'ajax':'condominia',
    'columns': [
	    {'data': 'name'},
	    {'data': 'description'},
	    {'data': 'actions'}
    ],
    'language': {'url': datatables_lang}
	})

  $("#form-disable-condominium").on("ajax:success", function(event) {
    condominia_table.ajax.reload(null,false)
    let msg = JSON.parse(event.detail[2].response)
    noty_alert(msg.status, msg.msg)
    $("#modal-disable-condominium").modal('hide')
  }).on("ajax:error", function(event) {
    let msg = JSON.parse( event.detail[2].response )
    noty_alert(msg.status, msg.msg)
  })

}) // End $(document).ready()