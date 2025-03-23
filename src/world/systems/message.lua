local messageSystem = tiny.sortedSystem()

messageSystem.filter = tiny.requireAll("message", "canvas")

function messageSystem:compare(e1, e2)
	return e1.message.when > e2.message.when
end

function messageSystem:update(dt)
	local font = self.world.resources.statsFont
    local textH = font:getHeight()
    local y = amora.settings.video.h - textH

	love.graphics.setFont(font)
	for i, e in ipairs(self.entities) do
        love.graphics.setCanvas(e.canvas)
        love.graphics.print(e.message.text, 0, y)

        y = y - textH
    end
end


return { message = messageSystem }
