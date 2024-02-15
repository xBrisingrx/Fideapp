let provider_roles_table

function modal_disable_provider_role(id) {
  $('#modal-disable-provider-role #provider_role_id').val(id)
  $('#modal-disable-provider-role').modal('show')
}

$(document).ready(function () {
  provider_roles_table = $("#provider-role-table").DataTable({
    'ajax': 'provider_roles',
    'columns': [
      { 'data': 'name' },
      { 'data': 'description' },
      { 'data': 'actions' }
    ],
    'language': { 'url': "/assets/plugins/datatables_lang_spa.json" }
  })

  $("#form-disable-provider-role").on("ajax:success", function (event) {
    provider_roles_table.ajax.reload(null, false)
    let msg = JSON.parse(event.detail[2].response)
    noty_alert(msg.status, msg.msg)
    $("#modal-disable-provider-role").modal('hide')
  }).on("ajax:error", function (event) {
    let msg = JSON.parse(event.detail[2].response)
    noty_alert(msg.status, msg.msg)
  })

}) // End $(document).ready()