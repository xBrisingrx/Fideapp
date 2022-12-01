let providers_table

function modal_disable_provider(id) {
  $('#modal-disable-provider #provider_id').val(id)
  $('#modal-disable-provider').modal('show')
}

$(document).ready(function(){
	providers_table = $("#providers-table").DataTable({
    'ajax':'providers',
    'columns': [
	    {'data': 'name'},
	    {'data': 'cuit'},
      {'data': 'activity'},
	    {'data': 'description'},
	    {'data': 'actions'}
    ],
    'language': {'url': "/assets/plugins/datatables_lang_spa.json"}
	})

  $("#form-disable-provider").on("ajax:success", function(event) {
    providers_table.ajax.reload(null,false)
    let msg = JSON.parse(event.detail[2].response)
    noty_alert(msg.status, msg.msg)
    $("#modal-disable-provider").modal('hide')
  }).on("ajax:error", function(event) {
    let msg = JSON.parse( event.detail[2].response )
    noty_alert(msg.status, msg.msg)
  })

}) // End $(document).ready()