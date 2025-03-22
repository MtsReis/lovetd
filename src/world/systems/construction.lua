local c = require("world.components")
local h = require("world.entities.handlers.attack")

local constructionSystem = tiny.processingSystem()

constructionSystem.filter = tiny.requireAll("construction")

function constructionSystem:process(e, dt)
	if e == constructionSystem.world.properties._construction then
        local mouse = constructionSystem.world.properties.mousePos
        e.pos.x, e.pos.y = mouse.x, mouse.y
    end
end

return { construction = constructionSystem }
