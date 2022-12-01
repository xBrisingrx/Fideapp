json.data @urbanizations do |u|
	json.name u.name
	json.actions "#{link_to '<i class="hs-admin-pencil"></i>'.html_safe, edit_urbanization_path(u), 
  								 :remote => true, 'data-toggle' =>  'modal',
      							'data-target' => '#modal-urbanization', 
      							'class' => 'u-link-v5 g-color-gray-light-v6 g-color-secondary--hover g-text-underline--none--hover g-ml-12', title: 'Editar'}
  							<a class='btn btn-sm u-btn-red g-color-white' 
  								title='Eliminar' 
  								onclick='modal_disable_urbanization( #{ u.id } )'>
									<i class='fa fa-trash-o' aria-hidden='true'></i></a>"
end