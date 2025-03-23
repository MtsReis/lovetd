local selectionSystem = tiny.processingSystem()

selectionSystem.filter = tiny.requireAll("pos", "selectionbox")

-- Update the mouse collisionpoint
function selectionSystem:preProcess(dt)
	selectionSystem.world.properties.mouse:moveTo(
		selectionSystem.world.properties.cam:worldCoords(love.mouse.getPosition())
	)
end

function selectionSystem:process(e, dt)
	e.selectionbox.shape:moveTo(e.pos.x, e.pos.y)

	if e.selectionbox.shape:collidesWith(selectionSystem.world.properties.mouse) and not selectionSystem.world.properties._construction then
		if love.mouse.isDown(1) then
			if e.selectionbox.hover then -- Prevent pressing while holding w/o collision in past frames
				e.selectionbox.pressed = true
			end
		else
			if e.selectionbox.pressed then -- Release when it was still pressed
				selectionSystem.world.properties.selectedEntity = e
			end

			e.selectionbox.pressed = false
			e.selectionbox.hover = true -- Only mark as hover when there's no click
		end
	else
		e.selectionbox.hover = false
		e.selectionbox.pressed = false
	end
end

return { selection = selectionSystem }
