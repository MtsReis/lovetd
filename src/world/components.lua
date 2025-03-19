--[[
	size: [w, h] vector
	pivot: [w, h] vector
]]
local function collisionbox(space, x, y, w, h, pivotx, pivoty)
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
		space:rectangle(x + collisionbox.pivot.x, y + collisionbox.pivot.y, collisionbox.w, collisionbox.h)

	return collisionbox
end

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

	--------
	-- Use collisionbox as base
	collisionbox = function(space, x, y, w, h, pivotx, pivoty)
		return collisionbox(space.bump, x, y, w, h, pivotx, pivoty)
	end,

	hitbox = function(space, x, y, w, h, pivotx, pivoty)
		return collisionbox(space.hit, x, y, w, h, pivotx, pivoty)
	end,

	hurtbox = function(space, x, y, w, h, pivotx, pivoty)
		return collisionbox(space.hit, x, y, w, h, pivotx, pivoty)
	end,

	triggerzone = function(space, x, y, w, h, pivotx, pivoty)
		return collisionbox(space.bump, x, y, w, h, pivotx, pivoty)
	end,

	selectionbox = function(space, x, y, w, h, pivotx, pivoty)
		local box = collisionbox(space.selection, x, y, w, h, pivotx, pivoty)
		box.hover = false
		box.pressed = false

		return box
	end,

	--------

	movement = function(velRad, speed, accelRad, accel)
		return {
			vel = { dir = vec2.fromAngle(velRad), speed = speed },
			accel = { dir = vec2.fromAngle(accelRad), magnitude = accel },
		}
	end,

	--------

	health = function(curr, max)
		return { curr = curr, max = max }
	end,

	--------

	attack = function(baseDamage, minDamageDecrement, maxDamageIncrement, cooldownTime)
		return {
			baseDamage = baseDamage,
			minDamageDecrement = minDamageDecrement,
			maxDamageIncrement = maxDamageIncrement,
			cooldownTime = cooldownTime,
			attackCycleTimer = 0,
		}
	end,

	target = function(targetEntity)
		return { targetEntity = targetEntity }
	end,

	range = function(space, x, y, value, visible)
		local range = { value = value, visible = visible }
		range.shape = space.bump:circle(x, y, value)

		return range
	end,

	action = function(curr, queue)
		return { curr = curr, queue = queue }
	end,
}
