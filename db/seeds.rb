User.create(name: 'David', username: 'david', email: 'fidev@fide.dev', password: 'asdasd', rol:1)

currencies = [ '$', 'US$', '€', 'Vechículo', 'Transferencia', 'Cheque' ]

currencies.each do |c|
	Currency.create!(name: c)
end

materials = [ 'Arena', 'Cemento', 'H21', 'Postes de luz']

materials.each do |m|
	Material.create!(name: m)
end

provider = [ 'Lic. Perez', 'Ing. Soto', 'Sagosa', 'Neomat']

provider.each do |p|
	Provider.create!(name: p)
end

condominia = [ 'Sin condominio asignado', 'CONDOMONIO PABLO TORRES', 'MARTIN BARRIENTOS ', 'COOP.MI SUEÑO']

condominia.each do |c|
	Condominium.create!(name: c)
end

urbanizations = [ 'SANTA BARBARA', 'LA ESTACION', 'LA RESERVA']

urbanizations.each do |c|
	u = Urbanization.create!(name: c)
end

Sector.create!(name: 'DIADEMA SUR', urbanization_id: 1)
Sector.create!(name: 'DIADEMA NORTE', urbanization_id: 1)
Sector.create!(name: 'CIUDADELA SUR', urbanization_id: 2)
Sector.create!(name: 'CIUDADELA NORTE', urbanization_id: 2)

project_types = [ 'Apertura de calles', 'Cordon cuneta', 'Movimiento de suelo', 'Cloaca']

project_types.each do |c|
	ProjectType.create!(name: c)
end

provider_roles = [ 'Dirección técnica', 'Inspección', 'Documentación']

provider_roles.each do |c|
	u = ProviderRole.create!(name: c)
end

pay_m = [ 'Valor fijo', 'Porcentaje']

pay_m.each do |c|
	u = PaymentMethod.create!(name: c)
end