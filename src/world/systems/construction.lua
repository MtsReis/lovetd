local c = require("world.components")
local h = require("world.entities.handlers.attack")

local constructionSystem = tiny.processingSystem()

constructionSystem.filter = tiny.requireAny("construction", "collisionbox")

function constructionSystem:process(e, dt)
	if e == self.world.properties._construction then
		local mouse = self.world.properties.mousePos
		e.pos.x, e.pos.y = mouse.x, mouse.y

		e.collisionbox.shape:moveTo(e.pos.x, e.pos.y)
		e.construction.blocked = false

		for _, otherEntity in pairs(self.entities) do
			-- Only entities with collisionbox and ignores sightRange
			if e ~= otherEntity and otherEntity.collisionbox then
				if e.collisionbox.shape:collidesWith(otherEntity.collisionbox.shape) then
					e.construction.blocked = true
				end
			end
		end
	end
end

return { construction = constructionSystem }
