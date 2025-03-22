local Entity = require("world.entities.entity")

local Construction = class("Construction", Entity)

function Construction:initialize(x, y, space, type, canvas, options)
	local W, H = 40, 40
	Entity.initialize(self, options)

	self.canvas = canvas

	self.pos = c.pos(x, y)
	self.rotation = c.rotation(0)
	self.geometry = c.geometry("rect", W, H, "fill", { 1, 0, 1, 1 })
	self.dPivot = c.dPivot(W / 2, H / 2)

	self.collisionbox = c.collisionbox(space, x, y, W, H, -W / 2, -H / 2)

	self.range = c.range(space, x, y, 130, true)
end

return Construction
