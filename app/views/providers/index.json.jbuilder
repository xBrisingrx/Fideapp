json.data @providers do |a|
	json.name a.name
	json.cuit a.cuit
	json.activity a.activity
	json.description a.description

	json.actions "#{link_to '<i class="hs-admin-pencil"></i>'.html_safe, edit_provider_path(a), 
  								 :remote => true, 'data-toggle' =>  'modal',
      							'data-target' => '#modal-provider', 
      							'class' => 'u-link-v5 g-color-gray-dark-v2 g-color-secondary--hover g-text-underline--none--hover g-ml-12', title: 'Editar'}
  							<a class='u-link-v5 g-color-gray-dark-v2 g-color-secondary--hover g-text-underline--none--hover g-ml-12' 
  								title='Eliminar' 
  								onclick='modal_disable_provider( #{ a.id } )'>
									<i class='hs-admin-trash' aria-hidden='true'></i></a>"
end
