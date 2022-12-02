json.data @project_types do |a|
	json.name a.name
	json.description a.description

	json.actions "#{link_to '<i class="hs-admin-pencil"></i>'.html_safe, edit_project_type_path(a), 
  								 :remote => true, 'data-toggle' =>  'modal',
      							'data-target' => '#modal-project-type', 
      							'class' => 'u-link-v5 g-color-gray-dark-v2 g-color-secondary--hover g-text-underline--none--hover g-ml-12', title: 'Editar'}
  							<a class='u-link-v5 g-color-gray-dark-v2 g-color-secondary--hover g-text-underline--none--hover g-ml-12' 
  								title='Eliminar' 
  								onclick='modal_disable_project_type( #{ a.id } )'>
									<i class='hs-admin-trash' aria-hidden='true'></i></a>"
end
