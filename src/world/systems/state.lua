local STATE_ENUM = require("world.components").STATE_ENUM
local EMPTY_ENTITY_DEFAULT_RANGE = 15

local stateSystem = tiny.processingSystem()

stateSystem.filter = tiny.requireAll("state", "pos")

function stateSystem:process(e, dt)
	-- MOVEMENT STATES
	if e.state == STATE_ENUM.idle then
		-- Switch to moving state if there's a path to follow
		if e.path then
			e.state = STATE_ENUM.movingAlongPath
		end

		-- Switch to attack state if there's a target
		if e.target and e.target.targetEntity then
			e.state = STATE_ENUM.attacking
		end
	elseif e.state == STATE_ENUM.movingAlongPath and e.path and e.movement then
		-- Don't loop the trajectory. Remove this in case looping might be necessary
		if e.path:getNextWpIndex() == 1 then
			e.path._currWp = #e.path.wps - 1

			return
		end

		-- Move along path
		local nextWp = e.path:getNextWp()

		local waypoint = vec2.new(nextWp[1], nextWp[2])

		if waypoint then
			local distance = e.pos:dist(waypoint)

			-- If we are close enough to the waypoint, advance
			if distance < e.movement.vel.speed * dt then
				e.pos.x = waypoint.x
				e.pos.y = waypoint.y
				e.path:advanceWp()
			else
				-- Move toward the waypoint
				local direction = waypoint - e.pos
				e.movement.vel.dir = direction:norm()

				-- Starts to accelerate if possible
				if e.movement.vel.speed < e.movement.maxSpeed then
					e.movement.accel.magnitude = e.movement.maxAccel
				end
			end
		end
	elseif e.state == STATE_ENUM.chasing then
		-- Move toward the enemy
		if e.target and e.target.targetEntity then
			-- If target's hurtbox is in attack range
			if e.range.shape:collidesWith(e.target.targetEntity.hurtbox.shape) then
				-- Enemy is in attack range, switch to Attacking state
				e.state = STATE_ENUM.attacking
				e.movement.vel.speed = 0
			else
				-- Move towards the enemy
				local direction = e.target.targetEntity.pos - e.pos
				e.movement.vel.dir = direction:norm()

				-- Starts to accelerate if possible
				if e.movement and e.movement.vel.speed < e.movement.maxSpeed then
					e.movement.accel.magnitude = e.movement.maxAccel
				end
			end
		else
			e.state = STATE_ENUM.idle
		end
	elseif e.state == STATE_ENUM.attacking then
		-- Stop if moving
		if e.movement then
			e.movement.vel.speed = 0
		end
		e.state = STATE_ENUM.idle
	end

	-- If there’s an enemy in sightRange, switch to Chasing state and ignore other states
	if e.target and e.target.targetEntity and e.target.targetEntity.collisionbox and e.movement and e.sightRange then
		if e.sightRange.shape:collidesWith(e.target.targetEntity.collisionbox.shape) then
			e.state = STATE_ENUM.chasing
		end
	end
end

return { state = stateSystem }
