json.data @payments_types do |payment_type|
	json.name payment_type.name
	
	list_currencies = '<ul>'
	payment_type.currencies.each do |currency|
		list_currencies += "<li>#{currency.name}</li>"
	end
	list_currencies += '</ul>'

	json.currencies list_currencies

	json.actions "#{link_to '<i class="hs-admin-plus"></i>'.html_safe, new_payments_currencies_path( payment_type_id: payment_type.id), 
  								 :remote => true, 'data-toggle' =>  'modal',
      							'class' => 'u-link-v5 g-color-gray-dark-v2 g-color-secondary--hover g-text-underline--none--hover g-ml-12', title: 'Agregar divisa'}
								#{link_to '<i class="hs-admin-pencil"></i>'.html_safe, '#', 
  								 :remote => true, 'data-toggle' =>  'modal',
      							'class' => 'u-link-v5 g-color-gray-dark-v2 g-color-secondary--hover g-text-underline--none--hover g-ml-12', title: 'Editar'}
  							<a class='u-link-v5 g-color-gray-dark-v2 g-color-secondary--hover g-text-underline--none--hover g-ml-12' 
  								title='Eliminar' 
  								onclick='modal_disable_material( #{ payment_type.id } )'>
									<i class='hs-admin-trash' aria-hidden='true'></i></a>"
end
