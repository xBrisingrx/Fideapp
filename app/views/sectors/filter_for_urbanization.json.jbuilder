json.data @sectors do |s|
	json.id s.id
	json.name "#{s.name} (#{s.apples.count})"
	json.apples s.apples.count
end
