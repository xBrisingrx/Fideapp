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

function setInputDate(_id){
    var _dat = document.querySelector(_id);
    var hoy = new Date(),
        d = hoy.getDate(),
        m = hoy.getMonth()+1, 
        y = hoy.getFullYear(),
        data;

    if(d < 10){
        d = "0"+d;
    };
    if(m < 10){
        m = "0"+m;
    };

    data = y+"-"+m+"-"+d;
    _dat.value = data;
}

function format_date(date) {
  let d = date.split('-')
  return `${d[2]}-${d[1]}-${d[0]}`
}

// Redondeo un numero a 2 decimales
function roundToTwo(num) {
    return +(Math.round(num + "e+2")  + "e-2")
}

// formato de numero para monedas
const numberFormat = new Intl.NumberFormat('es-AR')

function addClassValid( input ) {
  input.classList.remove('is-invalid')
  input.classList.add('is-valid')
}

function addClassInvalid( input ) {
  input.classList.remove('is-valid')
  input.classList.add('is-invalid')
}

function valid_number( value ) {
  if (!isNaN( value ) && value > 0 ) {
    return true
  } else {
    return false 
  }
}