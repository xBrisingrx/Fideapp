json.data @apples do |a|
	json.code a.code
	json.sector a.urbanization.name
	json.location a.sector.name
	json.hectares a.hectares
	json.space_not_available "#{a.space_not_available} m²"
	json.value "$ #{format_currency( a.get_value )}"
	json.condominium a.condominium.name
	json.actions "#{link_to '<i class="hs-admin-widgetized"></i>'.html_safe, apple_lands_path(a), 
      							'class' => 'u-link-v5 g-color-gray-dark-v2 g-color-secondary--hover g-text-underline--none--hover g-ml-12', title: 'Lotes'}
								#{link_to '<i class="hs-admin-pencil"></i>'.html_safe, edit_apple_path(a), 
  								 :remote => true, 'data-toggle' =>  'modal',
      							'data-target' => '#modal-apple', 
      							'class' => 'u-link-v5 g-color-gray-dark-v2 g-color-secondary--hover g-text-underline--none--hover g-ml-12', title: 'Editar'}
  							<a class='u-link-v5 g-color-gray-dark-v2 g-color-secondary--hover g-text-underline--none--hover g-ml-12' 
  								title='Eliminar' 
  								onclick='modal_disable_apple( #{ a.id } )'>
									<i class='hs-admin-trash' aria-hidden='true'></i></a>"
end
