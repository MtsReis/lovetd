local drawObjSystem = tiny.processingSystem()

drawObjSystem.filter = tiny.requireAll("pos", "canvas", "dPivot", tiny.requireAny("geometry", "sprite"))

function drawObjSystem:process(e, dt)
	local LINE_WIDTH = 2
	love.graphics.setCanvas(e.canvas)

	-- Pre drawing
	-- Range circle
	if e.range and e.range.visible and e.attack then
		love.graphics.setColor({ 1, 0, 1, 1 })
		love.graphics.setLineWidth(LINE_WIDTH)

		if e.action and e.action.curr == "attacking" then
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

			e.collisionbox.shape:draw('line')
		end
	end

	love.graphics.setLineWidth(1)
	love.graphics.setColor(1, 1, 1)
	love.graphics.setCanvas()
end

return { drawObj = drawObjSystem }
