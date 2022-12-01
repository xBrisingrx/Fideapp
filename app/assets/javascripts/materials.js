let materials_table

function modal_disable_material(id) {
  $('#modal-disable-material #material_id').val(id)
  $('#modal-disable-material').modal('show')
}

$(document).ready(function(){
	materials_table = $("#materials-table").DataTable({
    'ajax':'materials',
    'columns': [
	    {'data': 'name'},
	    {'data': 'description'},
	    {'data': 'actions'}
    ],
    'language': {'url': "/assets/plugins/datatables_lang_spa.json"}
	})

  $("#form-disable-material").on("ajax:success", function(event) {
    materials_table.ajax.reload(null,false)
    let msg = JSON.parse(event.detail[2].response)
    noty_alert(msg.status, msg.msg)
    $("#modal-disable-material").modal('hide')
  }).on("ajax:error", function(event) {
    let msg = JSON.parse( event.detail[2].response )
    noty_alert(msg.status, msg.msg)
  })

}) // End $(document).ready()