json.data @fees do |b|
	json.number b.number

	json.value "$#{format_currency(b.value)}"
	json.adjust "$#{format_currency(b.adjust)}"
	json.due_date b.due_date.strftime('%d-%m-%y')
	json.debe "$#{format_currency(b.owes)}"
	json.haber "$#{format_currency(b.payment)}"
	if b.expired? && !b.payed?
		json.pay_status "<span class='u-tags-v1 text-center g-width-100 g-brd-around g-brd-lightred-v2 g-bg-lightred-v2
											g-font-size-default g-color-white g-rounded-50 '>Cuota vencida</span>"
	else 
		if b.pagado?
			color = 'green'
		elsif b.pago_parcial? 
			color = 'deeporange'
		else 
			color = 'blue'
		end

		json.pay_status " <span class='u-tags-v1 text-center g-width-100 g-brd-around g-brd-#{color} g-bg-#{color}
											g-font-size-default g-color-white g-rounded-50 '>#{@status[b.pay_status]}</span> "
	end
	
	btn_detalle_pago = link_to "<i class='hs-admin-eye'></i>".html_safe, detalle_pagos_path(b.id), 
		                   :remote => true, 'data-toggle' =>  'modal', 'data-target' => '#modal-sales', 
		                    class: ' u-link-v5 g-color-white g-color-gray-dark-v2 g-color-secondary--hover g-text-underline--none--hover', 
		                    title: 'Detalle del pago de cuota'

	if !b.payed?
		json.actions "#{link_to "<i class='hs-admin-money'></i>".html_safe, fee_detail_path(b.id), 
                   :remote => true, 'data-toggle' =>  'modal', 'data-target' => '#modal-sales', 
                    class: ' u-link-v5 g-color-gray-dark-v2 g-color-secondary--hover g-text-underline--none--hover', title: 'Pagar cuota'}"
	elsif b.pago_parcial?
		json.actions "#{btn_detalle_pago}
                  #{link_to "<i class='hs-admin-money'></i>".html_safe, pago_parcial_path(b.id),
                  	:remote => true, 'data-toggle' =>  'modal', 'data-target' => '#modal-sales', 
                  	class: 'ml-4 u-link-v5 g-color-white g-color-gray-dark-v2 g-color-secondary--hover g-text-underline--none--hover', 
                    title: 'Pago parcial' }"
	else
		json.actions "#{btn_detalle_pago}"
	end
end