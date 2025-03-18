local movementSystem = tiny.processingSystem()

movementSystem.filter = tiny.requireAll("pos", "movement")

function movementSystem:process(e, dt)
	local velocity = e.movement.vel.dir * e.movement.vel.speed
	local deltaVelocity = e.movement.accel.dir * e.movement.accel.magnitude * dt

	local newVelocity = velocity + deltaVelocity

	e.movement.vel.speed = newVelocity:getmag()
    e.movement.vel.dir = newVelocity:norm()

	local deltaPosition = e.movement.vel.dir * e.movement.vel.speed * dt

	local newPos = e.pos + deltaPosition

	-- Affect the base rotation if the entity is moving
	if e.movement.vel.speed ~= 0 and e.rotation and e.pos ~= newPos then
		e.rotation = -e.movement.vel.dir:heading()
	end

	e.pos = newPos
end

-- Add trajectory system

return { movement = movementSystem }
