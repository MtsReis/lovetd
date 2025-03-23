local c = require("world.components")
local Entity = require("world.entities.entity")

local Blocker = class("Blocker", Entity)

function Blocker:initialize(x, y, space, w, h, options)
    Entity.initialize(self, options)

	self.pos = c.pos(x, y)
    self.collisionbox = c.collisionbox(space, x, y, w, h)
end

return Blocker
