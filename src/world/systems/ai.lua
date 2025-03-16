local AIMovementSystem = tiny.processingSystem()

AIMovementSystem.filter = tiny.requireAll("ai", "pos", "movement")

function AIMovementSystem:process(e, dt)
	if not e.movement.wishDir then
		e.movement.wishDir = vec2.fromAngle(0)
		e.movement.wishDir:norm()
	end
end

return { movement = AIMovementSystem }
