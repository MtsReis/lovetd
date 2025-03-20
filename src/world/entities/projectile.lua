local c = require("world.components")
local Entity = require("world.entities.entity")

local Projectile = class("Projectile", Entity)

function Projectile:initialize(x, y, space, type, invoker, canvas, options)
	Entity.initialize(self, options)
	local W, H = 10, 20

	self.canvas = canvas

	self.pos = c.pos(x, y)
	self.rotation = c.rotation(3.14)
	self.geometry = c.geometry("boid", W, H, "fill", { 0.5, 0, 1, 1 })
	self.dPivot = c.dPivot(0, 0)

	self.invoker = c.invoker(invoker)

	self.movement = c.movement(0, 100, 0, 2)
	self.hitbox = c.hitbox(space, x, y, H, W, 0, 0)
end

return Projectile
