local c = require("world.components")
local Entity = require("world.entities.entity")

local Blocker = class("Blocker", Entity)

function Blocker:initialize(x, y, space, w, h, options)
    Entity.initialize(self, options)

	self.pos = c.pos(x, y)
    self.collisionbox = c.collisionbox(space, x, y, w, h, 38, 38)

    self.rotation = c.rotation(0)

    self.canvas = options.canvas
    self.dPivot = c.dPivot( 0, 0)

    self.geometry = c.geometry("line", w, h, "fill", { 1, 0, 1, 0 })
end

return Blocker
