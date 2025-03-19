local c = require("world.components")
local Entity = class("Entity")
local count = 1

function Entity:initialize(options)
	if options then
		self.label = options.label
	end

	if not self.label then
		self.label = "entity_%(c)d_%(n)s" % { c = count, n = self.class.name }
		count = count + 1
	end
end

return Entity
