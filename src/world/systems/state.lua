local STATE_ENUM = require("world.components").STATE_ENUM

local stateSystem = tiny.processingSystem()

stateSystem.filter = tiny.requireAll("state", "pos")

function stateSystem:process(e, dt)
	if e.state == STATE_ENUM.idle then
		-- Switch to moving state if there's a path to follow
		if e.path then
			e.state = STATE_ENUM.movingAlongPath
		end
	elseif e.state == STATE_ENUM.movingAlongPath and e.path and e.movement then
        -- Don't loop the trajectory. Remove this in case looping might be necessary
        if e.path:getNextWpIndex() == 1 then
            e.state = STATE_ENUM.idle
            e.path = nil
            e.movement.vel.speed = 0

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
			end

			-- -- If there’s an enemy in range, switch to Chasing state
			-- if target then
			-- 	local targetDistance = math.sqrt((targetPos.x - position.x) ^ 2 + (targetPos.y - position.y) ^ 2)
			-- 	if targetDistance < enemyDetection.detectionRange then
			-- 		stateComponent.state = ChasingState
			-- 	end
			-- end
		end
	-- elseif stateComponent.state == ChasingState then
	-- 	-- Move toward the enemy
	-- 	if target then
	-- 		local dx = targetPos.x - position.x
	-- 		local dy = targetPos.y - position.y
	-- 		local distance = math.sqrt(dx * dx + dy * dy)

	-- 		if distance > velocity.speed * dt then
	-- 			-- Move toward the enemy
	-- 			position.x = position.x + (dx / distance) * velocity.speed * dt
	-- 			position.y = position.y + (dy / distance) * velocity.speed * dt
	-- 		else
	-- 			-- Enemy is in attack range, switch to Attacking state
	-- 			stateComponent.state = AttackingState
	-- 		end
	-- 	end
	-- elseif stateComponent.state == AttackingState then
	-- 	-- Perform attack logic (e.g., apply damage)
	-- 	print("Attacking enemy!")
	-- 	-- After attacking, return to idle or any other state (like moving again)
	-- 	stateComponent.state = IdleState
	end
end

return { state = stateSystem }
