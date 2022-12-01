let apples_table

function modal_disable_apple(id) {
  $('#modal-disable-apple #apple_id').val(id)
  $('#modal-disable-apple').modal('show')
}

$(document).ready(function(){
	apples_table = $("#apples-table").DataTable({
    'ajax':'apples',
    'columns': [
	    {'data': 'code'},
	    {'data': 'hectares'},
      {'data': 'space_not_available'},
	    {'data': 'location'},
	    {'data': 'value'},
	    {'data': 'sector'},
      {'data': 'condominium'},
	    {'data': 'actions'}
    ],
    'language': {'url': "/assets/plugins/datatables_lang_spa.json"}
	})

  $("#form-disable-apple").on("ajax:success", function(event) {
    apples_table.ajax.reload(null,false)
    let msg = JSON.parse(event.detail[2].response)
    noty_alert(msg.status, msg.msg)
    $("#modal-disable-apple").modal('hide')
  }).on("ajax:error", function(event) {
    let msg = JSON.parse( event.detail[2].response )
    noty_alert(msg.status, msg.msg)
  })

}) // End $(document).ready()