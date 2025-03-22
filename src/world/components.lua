local STATE_ENUM = { idle = "IDLE", movingAlongPath = "MOVING_PATH", chasing = "CHASING", attacking = "ATTACKING" }
local CONDITION_ENUM = { dead = "COND_DEAD" }
local EFFECT_ENUM = { slow = "EFF_SLOW", pierce = "EFF_PIERCE" }

local ASSETS_DIR = "assets/sprites/"
local ASSETS_EXT = ".png"

local DEFAULT_MAX_ACCEL = 50
local Path = class("Path")

function Path:initialize(waypoints)
	if type(waypoints) ~= "table" or not waypoints[1] or type(waypoints[1][1]) ~= "number" then
		log.error("Waypoints must contain at least 1 (x,y) point")
		waypoints = { { 0, 0 }, { 10, 10 } }
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

local function rangeCircle(space, x, y, value, visible)
	local range = { value = value, visible = visible }
	range.shape = space:circle(x, y, value)

	return range
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

	sprite = function(img, sx, sy)
		return { img = love.graphics.newImage(ASSETS_DIR .. img .. ASSETS_EXT), sx = sx or 1, sy = sy or 1 }
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

	movement = function(velRad, speed, accelRad, accel, maxSpeed, maxAccel)
		return {
			vel = { dir = vec2.fromAngle(velRad), speed = speed },
			accel = { dir = vec2.fromAngle(accelRad), magnitude = accel },
			maxSpeed = maxSpeed or speed,
			maxAccel = maxAccel or DEFAULT_MAX_ACCEL,
		}
	end,

	--------

	hp = function(curr, max)
		return { curr = curr, max = max }
	end,

	--------

	state = function(initialConditions)
		local state = initialState or "idle"
		return STATE_ENUM[state] or STATE_ENUM["idle"]
	end,

	--------

	attack = function(baseDamage, minDamageDecrement, maxDamageIncrement, cooldownTime, ranged)
		return {
			baseDamage = baseDamage,
			minDamageDecrement = minDamageDecrement,
			maxDamageIncrement = maxDamageIncrement,
			cooldownTime = cooldownTime,
			attackCycleTimer = 0,
			ranged = ranged or false,
		}
	end,

	--------
	-- Use rangeCircle as base
	-- Attack range, for attacking state
	range = function(space, x, y, value, visible)
		return rangeCircle(space.hit, x, y, value, visible)
	end,

	-- Sight range, mostly for chasing
	sightRange = function(space, x, y, value, visible)
		return rangeCircle(space.bump, x, y, value, amora.debugMode)
	end,

	--------

	target = function(targetEntity)
		return { targetEntity = targetEntity }
	end,

	----------------
	-- CONDITIONS --
	----------------
	COND_DEAD = function()
		return true
	end,

	----------------
	-- EFFECTS --
	----------------
	EFF_SLOW = function(percentage)
		return percentage
	end,

	EFF_PIERCE = function(amount)
		return amount
	end,

	--------

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

	--------

	lifespan = function(seconds)
		return seconds or 1
	end,

	--------

	spawnOverTime = function(cooldownTime, amount, blueprint, ...)
		return {
			amount = amount,
			cooldownTime = cooldownTime,
			spawnCycleTimer = 0,
			args = table.pack(...),
			blueprint = blueprint,
		}
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
	CONDITION_ENUM = CONDITION_ENUM,
	EFFECT_ENUM = EFFECT_ENUM,
}
