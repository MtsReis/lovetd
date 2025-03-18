return {
	pos = function(x, y)
		return vec2.new(x, y)
	end,

	rotation = function(angle)
		return angle
	end,

	geometry = function(type, w, h, mode, colour)
		if type ~= "circ" and type ~= "boid" then
			type = "rect"
		end

		-- Circle: w = radius
		-- Triangle: w = base
		-- Boid: h = length
		return { w = w, h = h, mode = mode, colour = colour, type = type }
	end,

	dPivot = function(x, y)
		if type(x) == "nil" then
			return vec2.new(0, 0)
		end

		return vec2.new(x, y)
	end,

	range = function(space, x, y, value, visible)
		local range = { value = value, visible = visible }
		range.shape = space.bump:circle(x, y, value)

		return range
	end,

	movement = function(velRad, speed, accelRad, accel)
		return {
			vel = { dir = vec2.fromAngle(velRad), speed = speed },
			accel = { dir = vec2.fromAngle(accelRad), magnitude = accel },
		}
	end,

	--[[
    size: [w, h] vector
    pivot: [w, h] vector
    ]]
	collisionbox = function(space, x, y, w, h, pivotx, pivoty)
		local collisionbox = { size = vec2.new(w, h), pivot = vec2.new(pivotx, pivoty) }

		setmetatable(collisionbox, {
			__index = function(table, key)
				if key == "w" then
					return table.size.x
				end
				if key == "h" then
					return table.size.y
				end
			end,
		})

		collisionbox.shape =
			space.bump:rectangle(x + collisionbox.pivot.x, y + collisionbox.pivot.y, collisionbox.w, collisionbox.h)

		return collisionbox
	end,

	action = function(curr, queue)
		return { curr = curr, queue = queue }
	end,
}
