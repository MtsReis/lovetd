local LINE_WIDTH = 2
local drawObjSystem = tiny.processingSystem()

drawObjSystem.filter = tiny.requireAll("pos", "rotation", "canvas", "dPivot", tiny.requireAny("geometry", "sprite"))

function drawObjSystem:process(e, dt)
	love.graphics.setCanvas(e.canvas)

	-- Pre drawing
	-- Range circle
	if e.range and e.range.visible and e.attack then
		love.graphics.setColor({ 1, 0, 1, 1 })
		love.graphics.setLineWidth(LINE_WIDTH)

		if e.action and e.action.curr.attacking then
			love.graphics.setColor({ 1, 0, 0, 1 })
		end

		love.graphics.circle("line", e.pos.x, e.pos.y, e.range.value)
	end

	-- Obj drawing

	if e.sprite then
	elseif e.geometry then
		local posx = e.pos.x - e.dPivot.x
		local posy = e.pos.y - e.dPivot.y

		love.graphics.setColor(e.geometry.colour)

		if e.geometry.type and e.geometry.type == "circ" then
			love.graphics.circle(e.geometry.mode, posx, posy, e.geometry.w)
		elseif e.geometry.type and e.geometry.type == "boid" then
			love.graphics.push()
			love.graphics.translate(posx, posy)
			love.graphics.rotate(e.rotation)
			love.graphics.polygon(
				e.geometry.mode,
				-e.geometry.h / 2,
				-e.geometry.w / 2,
				-e.geometry.h / 2,
				e.geometry.w / 2,
				e.geometry.h / 2,
				0
			)
			love.graphics.pop()
		else
			love.graphics.rectangle(e.geometry.mode, posx, posy, e.geometry.w, e.geometry.h)
		end
	end

	-- Post drawing
	-- Collision Boxes
	if amora.debugMode then
		if e.collisionbox then
			love.graphics.setColor({ 1, 1, 1, 1 })
			love.graphics.setLineWidth(LINE_WIDTH)

			e.collisionbox.shape:draw("line")
		end
	end

	love.graphics.setLineWidth(1)
	love.graphics.setColor(1, 1, 1)
	love.graphics.setCanvas()
end

function drawObjSystem:postProcess(dt)
	if drawObjSystem.world.properties.selectedEntity and amora.debugMode then
		local e = drawObjSystem.world.properties.selectedEntity

		love.graphics.setCanvas(e.canvas)
		love.graphics.setColor({ 1, 0.75, 0, 1 })
		love.graphics.setLineWidth(LINE_WIDTH)

		love.graphics.circle("line", e.pos.x, e.pos.y, e.geometry.w / 2)

		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.rectangle("fill", 0, 0, 500, drawObjSystem.world.properties.height)

		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.print(
			"%(l)s\nCollision: %(cb)s\nMovement: %(m)s\nAttack: %(a)s\nTarget: %(t)s\nRange: %(r)s\nAction: %(act)s\n"
				% {
					l = e.label,
					cb = pw(e.collisionbox),
					m = pw(e.movement),
					a = pw(e.attack),
					t = pw(e.target),
					r = pw(e.range),
					act = pw(e.action),
				},
			0,
			0
		)

		love.graphics.setLineWidth(1)
		love.graphics.setColor(1, 1, 1)
		love.graphics.setCanvas()
	end
end

return { drawObj = drawObjSystem }
