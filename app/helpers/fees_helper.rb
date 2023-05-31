module FeesHelper
	
	def btn_fee_show fee
		"#{link_to "<i class='hs-admin-money'></i>".html_safe, fee_path(fee.id), 
                     :remote => true, 'data-toggle' =>  'modal',
                      class: ' u-link-v5 g-color-gray-dark-v2 g-color-secondary--hover g-text-underline--none--hover', title: 'Pagar cuota'}".html_safe
	end

	def btn_fee_pay_detail fee
		link_to "<i class='hs-admin-eye'></i>".html_safe, detalle_pagos_path(fee.id), 
                       :remote => true, 'data-toggle' =>  'modal',
                        class: ' u-link-v5 g-color-white g-color-gray-dark-v2 g-color-secondary--hover g-text-underline--none--hover', 
                        title: 'Detalle del pago de cuota'
	end

	def btn_fee_partial_pay fee
		link_to "<i class='hs-admin-money'></i>".html_safe, pago_parcial_path(fee.id),
                    :remote => true, 'data-toggle' =>  'modal', 
                    class: 'ml-4 u-link-v5 g-color-white g-color-gray-dark-v2 g-color-secondary--hover g-text-underline--none--hover', 
                    title: 'Pago parcial'
	end

	def btn_payment sale_id, fee_id
		"#{link_to "<i class='hs-admin-money'></i>".html_safe, new_payment_path(sale_id: sale_id, fee_id: fee_id), 
                     :remote => true, 'data-toggle' =>  'modal',
                      class: ' u-link-v5 g-color-gray-dark-v2 g-color-secondary--hover g-text-underline--none--hover', title: 'Pagar cuota'}".html_safe
	end

end