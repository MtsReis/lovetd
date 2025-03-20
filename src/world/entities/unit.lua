local c = require("world.components")
local Entity = require("world.entities.entity")

local Unit = class("Unit", Entity)

function Unit:initialize(x, y, space, type, canvas, options)
	local W, H = 20, 20
	Entity.initialize(self, options)

	self.canvas = canvas

	self.pos = c.pos(x, y)
	self.rotation = c.rotation(0)
	self.geometry = c.geometry("rect", W, H, "fill", { 1, 0, 0, 1 })
	self.dPivot = c.dPivot(W / 2, H / 2)

	self.movement = c.movement(0, 500, 0, 0)
	self.collisionbox = c.collisionbox(space, x, y, W, H, 0, 0)
	self.hurtbox = c.hurtbox(space, x, y, W, H, 0, 0)
	self.hp = c.hp(20, 20)

	if type == "orc" then
		self.geometry.type = "circ"
		self.geometry.colour = { 50 / 255, 148 / 255, 44 / 255, 1 }
		self.dPivot = c.dPivot()
		self.movement.vel.speed = 50
		self.collisionbox = c.collisionbox(space, x, y, W, H, -W / 2, -H / 2)
		self.selectionbox = c.selectionbox(space, x, y, W, H, -W / 2, -H / 2)

		self.hp = c.hp(100, 100)
	elseif type == "human" then
		self.geometry.colour = { 10 / 255, 10 / 255, 10 / 255, 1 }
		self.movement.vel.speed = 90

		self.hp = c.hp(50, 50)
	end
end

return Unit
