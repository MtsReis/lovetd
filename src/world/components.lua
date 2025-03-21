local STATE_ENUM = { idle = "IDLE", movingAlongPath = "MOVING_PATH", chasing = "CHASING", attacking = "ATTACKING" }
local Path = class("Path")

function Path:initialize(waypoints)
	if type(waypoints) ~= "table" or not waypoints[1] or type(waypoints[1][1]) ~= "number" then
		log.error("Waypoints must contain at least 1 (x,y) point")
		waypoints = {{0, 0}, {10, 10}}
	end

	self.wps = waypoints
	self._currWp = 1
end

function Path:getNextWpIndex()
	return (self._currWp + 1 > #self.wps) and 1 or self._currWp + 1
end

function Path:getNextWp()
	return self.wps[self:getNextWpIndex()]
end

function Path:advanceWp()
	self._currWp = self:getNextWpIndex()
end

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

	if w ~= 0 or h ~= 0 then
		collisionbox.shape =
			space:rectangle(x + collisionbox.pivot.x, y + collisionbox.pivot.y, collisionbox.w, collisionbox.h)
	else
		collisionbox.shape = space:point(x + collisionbox.pivot.x, y + collisionbox.pivot.y)
	end

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
		local box = collisionbox(space.hit, x, y, w, h, pivotx, pivoty)
		box.wasAffectedBy = {}
		return box
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

	hp = function(curr, max)
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

	state = function(initialState)
		local state = initialState or "idle"
		return STATE_ENUM[state] or STATE_ENUM["idle"]
	end,

	invoker = function(invoker)
		--print(invoker.class.super.name)
		if invoker and invoker.class and invoker.class.super.name == "Entity" then
			return invoker
		end

		return nil
	end,

	stance = function(mode)
		if mode == "pacific" then
			return mode
		end

		return "aggressive"
	end,

	team = function(teamNumber)
		return teamNumber or 2
	end,

	--------

	path = function(waypoints)
		return Path:new(waypoints)
	end,

	-------------------
	-- Especial values
	-------------------
	_effects_agent_on_target_once = {
		"attack",
		"eff_slow",
	},
	_effects_agent_on_target_constant = {},
	STATE_ENUM = STATE_ENUM,
}
