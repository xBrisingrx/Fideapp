let project_types_table

function modal_disable_project_type(id) {
  $('#modal-disable-project-type #project_type_id').val(id)
  $('#modal-disable-project-type').modal('show')
}

$(document).ready(function(){
	project_types_table = $("#project-types-table").DataTable({
    'ajax':'project_types',
    'columns': [
	    {'data': 'name'},
	    {'data': 'description'},
	    {'data': 'actions'}
    ],
    'language': {'url': "/assets/plugins/datatables_lang_spa.json"}
	})

  $("#form-disable-project-type").on("ajax:success", function(event) {
    project_types_table.ajax.reload(null,false)
    let msg = JSON.parse(event.detail[2].response)
    noty_alert(msg.status, msg.msg)
    $("#modal-disable-project-type").modal('hide')
  }).on("ajax:error", function(event) {
    let msg = JSON.parse( event.detail[2].response )
    noty_alert(msg.status, msg.msg)
  })

}) // End $(document).ready()