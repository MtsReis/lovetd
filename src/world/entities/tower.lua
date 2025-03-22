local c = require("world.components")
local Entity = require("world.entities.entity")
local EFFECT = c.EFFECT_ENUM

local Tower = class("Tower", Entity)

function Tower:initialize(x, y, space, type, canvas, options)
	local W, H = 40, 40
	Entity.initialize(self, options)

	self.canvas = canvas

	self.pos = c.pos(x, y)
	self.rotation = c.rotation(0)
	self.geometry = c.geometry("rect", W, H, "fill", { 1, 0, 1, 1 })
	self.dPivot = c.dPivot(W / 2, H / 2)

	self.selectionbox = c.selectionbox(space, x, y, W, H, -W / 2, -H / 2)
	self.collisionbox = c.collisionbox(space, x, y, W, H, -W / 2, -H / 2)
	self.hurtbox = c.hurtbox(space, x, y, W, H, -W / 2, -H / 2)

	self.state = c.state("idle")

	self.hp = c.hp(100, 100)

	self.stance = c.stance("aggressive")
	self.attack = c.attack(10, 2, 3, 1, true)
	self.range = c.range(space, x, y, 100, true)
	self.target = c.target()

	self.team = c.team(1)
end

return Tower
