json.data @lands do |f|
	json.owners f.sale_clients.map { |c| "<li>#{c.client.fullname}</li>" }
	json.code f.code
	json.area "#{f.area} m²"
	json.ubication f.ubication
	json.price "$ #{format_currency(f.price) }"
	json.is_green_space (f.is_green_space)? 'Si' : 'No'
	json.is_corner (f.is_corner)? 'Si' : 'No'
	json.status "#{@status[f.status]}"
	json.bought_date ( f.bought? ) ? f.land_sale_date : ''
	if f.blueprint.attached?
		json.blueprint "#{link_to "<i class= 'hs-admin-file'></i>".html_safe, f.blueprint, target: '_blank', class: 'btn u-btn-indigo', title: 'Ver plano'}"
	else
		json.blueprint "<button class='btn u-btn-orange' disabled title='No se adjunto ningun plano'><i class= 'hs-admin-file'></i></button>"
	end

	if f.available?
		json.actions "#{link_to '<i class="hs-admin-pencil"></i>'.html_safe, edit_apple_land_path(apple_id:f.apple_id, id: f.id), 
  								 :remote => true, 'data-toggle' =>  'modal',
      							'data-target' => '#modal-land', 
      							'class' => 'u-link-v5 g-color-gray-dark-v2 g-color-secondary--hover g-text-underline--none--hover g-ml-12', title: 'Editar'}
									#{link_to '<i class="hs-admin-money"></i>'.html_safe, new_sale_path( land_id: f.id, product_type: :land, product_id: f.id ), 
  								 :remote => true, 'data-toggle' =>  'modal',
      							'data-target' => '#modal-land', 
      							'class' => 'u-link-v5 g-color-gray-dark-v2 g-color-secondary--hover g-text-underline--none--hover g-ml-12', title: 'Vender'}
  							<a class='u-link-v5 g-color-gray-dark-v2 g-color-secondary--hover g-text-underline--none--hover g-ml-12' 
  								title='Eliminar' 
  								onclick='modal_disable_land( #{ f.id } )'>
									<i class='hs-admin-trash' aria-hidden='true'></i></a>"
	end 
	if f.bought? 
		botones = "#{link_to '<i class="hs-admin-credit-card"></i>'.html_safe, land_detail_sales_path( id: f.id ), 
      							'class' => 'u-link-v5 g-color-gray-dark-v2 g-color-secondary--hover g-text-underline--none--hover g-ml-12', title: 'Ver cuotas'}
      						<a  onclick='sale.modal_destroy( `#{f.land_sale.sale.id}` , `#{f.apple.code}`, `#{f.code}`)' class='u-link-v5 g-color-gray-dark-v2 g-color-secondary--hover g-text-underline--none--hover g-ml-12'><i class='hs-admin-trash'></i></a>
      						"
      	# if f.land_projects.count > 0
      	# 	f.land_projects.each do |project|

      	# 		if project.status == 'pending'
      	# 			botones = botones + "#{link_to '<i class="fa fa-car"></i>'.html_safe, '#', 
      	# 						'class' => 'u-link-v5 g-color-gray-dark-v2 g-color-secondary--hover g-text-underline--none--hover g-ml-12', title: 'Financiar projecto'}"
      	# 		end
      	# 	end
      	# end
    json.actions botones
	end
end

