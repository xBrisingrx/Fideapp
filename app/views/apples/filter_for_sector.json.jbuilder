json.data @apples do |a|
	json.id a.id
	json.code "#{a.code} (#{a.lands.count})"
	json.lands a.lands.count
	json.has_corner a.has_corner
	json.count_corners a.count_corners
end
