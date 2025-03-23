local LINE_WIDTH = 2
local drawObjSystem = tiny.sortedProcessingSystem()

drawObjSystem.filter = tiny.requireAll("pos", "rotation", "canvas", "dPivot", "geometry")

function drawObjSystem:compare(e1, e2)
	return e1.pos.y < e2.pos.y
end

function drawObjSystem:process(e, dt)
	love.graphics.setCanvas(e.canvas)

	-- Pre drawing
	-- Range circle
	if e.sightRange and e.sightRange.visible then
		love.graphics.setColor({ 1, 0.5, 0.3, 1 })
		love.graphics.setLineWidth(LINE_WIDTH)

		if e.target and e.target.targetEntity then
			love.graphics.setColor({ 1, 0.7, 0.5, 1 })
		end

		love.graphics.circle("line", e.pos.x, e.pos.y, e.sightRange.value)
	end

	if
		e.range
		and e.attack
		and e.attack.ranged
		and (e.range.visible or self.world.properties.selectedEntity == e)
	then
		love.graphics.setColor({ 1, 0, 1, 1 })
		love.graphics.setLineWidth(LINE_WIDTH)

		if e.target and e.target.targetEntity then
			love.graphics.setColor({ 1, 0, 0, 1 })
		end

		love.graphics.circle("line", e.pos.x, e.pos.y, e.range.value)
	end

	-- Obj drawing

	if e.sprite then
		if e.construction then
			love.graphics.setColor(e.colour or { 1, 1, 1, 0.7 })
		else
			love.graphics.setColor(e.colour or { 1, 1, 1, 1 })
		end
		love.graphics.draw(e.sprite.img, e.pos.x, e.pos.y, 0, e.sprite.sx, e.sprite.sy, e.dPivot.x, e.dPivot.y)
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
			love.graphics.setLineWidth(1)

			e.collisionbox.shape:draw("line")
		end

		if e.hitbox then
			love.graphics.setColor({ 1, 0, 0, 1 })
			love.graphics.setLineWidth(LINE_WIDTH)

			e.hitbox.shape:draw("line")
		end

		if e.hurtbox then
			love.graphics.setColor({ 0, 0, 1, 1 })
			love.graphics.setLineWidth(LINE_WIDTH)

			e.hurtbox.shape:draw("line")
		end
	end

	love.graphics.setLineWidth(1)
	love.graphics.setColor(1, 1, 1)
	love.graphics.setCanvas()
end

function drawObjSystem:postProcess(dt)
	if self.world.properties.selectedEntity and amora.debugMode then
		local e = self.world.properties.selectedEntity

		love.graphics.setCanvas(e.canvas)
		love.graphics.setColor({ 1, 0.75, 0, 1 })
		love.graphics.setLineWidth(LINE_WIDTH)

		love.graphics.circle("line", e.pos.x, e.pos.y, e.geometry.w / 2)

		love.graphics.print(e.label .. "\n" .. pw(e.range), 0, 0)

		love.graphics.setLineWidth(1)
		love.graphics.setColor(1, 1, 1)
		love.graphics.setCanvas()
	end
end

return { drawObj = drawObjSystem }
