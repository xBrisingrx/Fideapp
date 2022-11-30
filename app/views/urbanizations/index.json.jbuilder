json.data @urbanizations do |u|
	json.name u.name
	json.actions "#{link_to '<i class="hs-admin-pencil"></i>'.html_safe, edit_urbanization_path(u), 
  								 :remote => true, 'data-toggle' =>  'modal',
      							'data-target' => '#modal-urbanization', 
      							'class' => 'u-link-v5 g-color-gray-light-v6 g-color-secondary--hover g-text-underline--none--hover g-ml-12', title: 'Editar'}
  							<a class='u-link-v5 g-color-gray-light-v6 g-color-secondary--hover g-text-underline--none--hover g-ml-12' 
  								title='Eliminar' 
  								onclick='modal_disable_urbanization( #{ u.id } )'>
									<i class='hs-admin-trash' aria-hidden='true'></i></a>"
end