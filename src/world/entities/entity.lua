local c = require("world.components")

local Entity = class("Entity")

function Entity:initialize(options)
	if options then
		self.label = options.label
	end
end

return Entity
