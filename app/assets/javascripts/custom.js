const datatables_lang = "/assets/plugins/datatables_lang_spa.json";
const meses = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Deciembre"];

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

function date_to_string(date){
  var   d = date.getDate(),
        m = date.getMonth()+1, 
        y = date.getFullYear(),
        data;

    if(d < 10){
        d = "0"+d;
    };
    if(m < 10){
        m = "0"+m;
    };

    data = y+"-"+m+"-"+d;
    return data
}

function format_date(date) {
  let d = date.split('-')
  return `${d[2]}-${d[1]}-${d[0]}`
}

// Redondeo un numero a 2 decimales
function roundToTwo(num) {
    return +(Math.round(num + "e+2")  + "e-2")
}

// formato de numero para monedas , uso numberFormat.format( number )
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
  return ( !isNaN( value ) && value > 0 )
}

function close_modal( modal_id) {
  $(`#${modal_id}`).modal('hide')
}

function formatNumber(n) {
  // format number 1000000 to 1.234.567
  return n.replace(/\D/g, "").replace(/\B(?=(\d{3})+(?!\d))/g, ".")
}

function formatCurrency(input, blur) {
  // appends $ to value, validates decimal side
  // and puts cursor back in right position.

  // get input value
  var input_val = input.val();

  // don't validate empty input
  if (input_val === "") { return; }

  // original length
  var original_len = input_val.length;

  // initial caret position 
  var caret_pos = input.prop("selectionStart");
    
  // check for decimal
  if (input_val.indexOf(",") >= 0) {

    // get position of first decimal
    // this prevents multiple decimals from
    // being entered
    var decimal_pos = input_val.indexOf(",");

    // split number by decimal point
    var left_side = input_val.substring(0, decimal_pos);
    var right_side = input_val.substring(decimal_pos);

    // add commas to left side of number
    left_side = formatNumber(left_side);

    // validate right side
    right_side = formatNumber(right_side);
    
    // On blur make sure 2 numbers after decimal
    if (blur === "blur") {
      right_side += "00";
    }
    
    // Limit decimal to only 2 digits
    right_side = right_side.substring(0, 2);

    // join number by .
    input_val = "$" + left_side + "," + right_side;

  } else {
    // no decimal entered
    // add commas to number
    // remove all non-digits
    input_val = formatNumber(input_val);
    input_val = "$" + input_val;
    
    // final formatting
    if (blur === "blur") {
      input_val += ",00";
    }
  }

  // send updated string to input
  input.val(input_val);

  // put caret back in the right position
  var updated_len = input_val.length;
  caret_pos = updated_len - original_len + caret_pos;
  input[0].setSelectionRange(caret_pos, caret_pos);
}

function string_to_float(input_id){
  // parse a string wiht format "$1.234.567,1" to 1234567.1
	const string = document.getElementById(input_id).value
  if(string != ''){
    return parseFloat(string.replace('$', '').replaceAll('.', '').replace(',', '.'))
  } else {
    return 0
  }
}

function float_to_string( value ) {
  let string = `${value}`
  return string.replace('.',',')
}

function string_to_float_with_value(string_value){
  // parse a string wiht format "$1.234.567,1" to 1234567.1
  if(string_value != ''){
    return parseFloat(string_value.replace('$', '').replaceAll('.', '').replace(',', '.'))
  } else {
    return 0
  }
}

function set_currency_fn(){
  $("input[data-type='currency']").on({
    keyup: function() {
      formatCurrency($(this));
    },
    blur: function() { 
      formatCurrency($(this), "blur");
    }
  })
}

function string_to_currency(string_value){
  // si paso un numero con decimales el formatNumber lo formatea mal, por ese motivo lo separo
  const split_value = string_value.replace('.', ',').split(',') // separo pesos de centavos
  string_value = '$'+formatNumber( split_value[0] ) + ','
  // si tiene centavos se lo sumamos
  string_value += ( split_value[1] != undefined ) ? split_value[1] : '00'
  return string_value
}