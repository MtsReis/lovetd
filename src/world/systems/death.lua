local c = require("world.components")
local CONDITION = c.CONDITION_ENUM

local deathSystem = tiny.processingSystem()

deathSystem.filter = tiny.requireAll("hp")

function deathSystem:process(e, dt)
	if e.hp.curr <= 0 and not e[CONDITION.dead] then
        e.lifespan = c.lifespan(2)
        e[CONDITION.dead] = c[CONDITION.dead]()
    end
end

return { death = deathSystem }
