const datatables_lang = "/assets/plugins/datatables_lang_spa.json";

function noty_alert(type, message, time = 7000) {
  let icon = ''
  switch (type) {
    case 'success':
      icon = 'hs-admin-check' 
      break 
    case 'error':
      icon = 'hs-admin-check' 
    break 
    case 'info':
      icon = 'hs-admin-help-alt'
    break
    case 'warning':
      icon = 'hs-admin-alert' 
  }

  const newNoty = new Noty({
    "type": type,
    "layout": "topRight",
    "timeout": 7000,
    "animation": {
      "open": "animated fadeIn",
      "close": "animated fadeOut"
    },
    "closeWith": [
      "click"
    ],
    "text": `<div class="g-mr-20"><div class="noty_body__icon"><i class="${icon}"></i></div></div><div>${message}.</div>`,
    "theme": "unify--v1"
  }).show();
}