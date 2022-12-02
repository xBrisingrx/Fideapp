json.data @apples do |a|
	json.id a.id
	json.code a.code
	json.lands a.lands.count
	json.has_corner a.has_corner
end
