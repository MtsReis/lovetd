local c = require("world.components")
local Entity = require("world.entities.entity")

local Projectile = class("Projectile", Entity)

function Projectile:initialize(invoker, type, space, options)
	Entity.initialize(self, options)
	local x = options.x or invoker.pos.x or nil
	local y = options.y or invoker.pos.y or nil
	local rotation = options.rotation or invoker.rotation or 0
	local canvas = options.canvas or invoker.canvas or nil
	local dPivot = options.dPivot or c.dPivot(0, 0)

	space = space or options.space or invoker.space or nil

	local w = options.w or 10
	local h = options.h or 20

	self.invoker = c.invoker(invoker)

	self.canvas = canvas

	self.pos = c.pos(x, y)
	self.rotation = c.rotation(rotation)
	self.geometry = c.geometry("boid", w, h, "fill", { 0.5, 0, 1, 1 })
	self.dPivot = dPivot

	self.movement = c.movement(self.rotation, 100, 0, 2)

	self.hitbox = c.hitbox(space, x, y, h, w, 0, 0)
end

return Projectile
