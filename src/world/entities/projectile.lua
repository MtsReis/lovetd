local c = require("world.components")
local Entity = require("world.entities.entity")

local Projectile = class("Projectile", Entity)

function Projectile:initialize(x, y, space, type, canvas, options)
	Entity.initialize(self, options)

	local W, H = 10, 20
	self.canvas = canvas

	self.pos = c.pos(x, y)
    self.rotation = c.rotation(3.14)
	self.geometry = c.geometry("boid", W, H, "fill", { .5, 0, 1, 1 } )
	self.dPivot = c.dPivot(W / 2, H / 2)

	self.movement = c.movement(0, 100, math.pi - .1, 30)
	self.collisionbox = c.collisionbox(space, x, y, W, H, 0, 0)		
end

return Projectile
