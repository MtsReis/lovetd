return function(...)
	local arg = { ... }
	local waypoints = {}

	for i, v in ipairs(arg) do
		if type(v[1] == "number") and type(v[2] == "number") then
			table.insert(waypoints, v)
		else
			log.warn("Invalid data for path waypoint: %(v)s" % { v = pw(v) })
		end
	end

	return waypoints
end
