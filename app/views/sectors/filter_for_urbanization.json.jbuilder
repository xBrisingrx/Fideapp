json.data @sectors do |s|
	json.id s.id
	json.name s.name
	json.apples s.apples.count
end
