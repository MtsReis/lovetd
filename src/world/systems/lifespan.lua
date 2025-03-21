local c = require("world.components")
local lifespanSystem = tiny.processingSystem()

lifespanSystem.filter = tiny.requireAll("lifespan")

function lifespanSystem:process(e, dt)
	if type(e.lifespan) == "number" then
		if e.lifespan <= 0 then
			e._REMOVED = true
			lifespanSystem.world:removeEntity(e)
		else
			e.lifespan = e.lifespan - dt
		end
	end
end

----------------

local clearReferencesSystem = tiny.processingSystem()

clearReferencesSystem.filter = tiny.requireAll("target")

function clearReferencesSystem:process(e, dt)
	if e.target and e.target.targetEntity and e.target.targetEntity._REMOVED then
		e.target = c.target(nil)
	end
end

return { lifespan = lifespanSystem, clearReferences = clearReferencesSystem }
