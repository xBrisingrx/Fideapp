json.data @currencies do |currency|
	json.name currency.name
	json.need_exchange (currency.need_exchange) ? 'Si' : 'No'
	json.detail currency.detail

	json.actions "---"
end
