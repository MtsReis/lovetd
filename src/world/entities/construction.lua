local c = require("world.components")

local Entity = require("world.entities.entity")

local Construction = class("Construction", Entity)

function Construction:initialize(x, y, space, type, canvas, options)
	local W, H = 40, 40
	Entity.initialize(self, options)
	local cost = 10

	if type == "face" then
		cost = 20
		self.sprite = c.sprite("tower1")

		self.attack = c.attack(1, 2, 3, 0.08, true)
		self.range = c.range(space, x, y, 130, true)

		W, H = 64, 64
		self.dPivot = c.dPivot(self.sprite.img:getWidth() - W / 2 - 13, self.sprite.img:getHeight() - H / 2)
	elseif type == "tall" then
		cost = 35
		self.sprite = c.sprite("tower2")

		self.attack = c.attack(25, 2, 3, 2, true)
		self.range = c.range(space, x, y, 330, true)

		W, H = 64, 64
		self.dPivot = c.dPivot(self.sprite.img:getWidth() - W / 2 - 17, self.sprite.img:getHeight() - H / 2)
	elseif type == "ritual" then
		cost = 40
		self.sprite = c.sprite("tower3")

		self.attack = c.attack(25, 2, 3, 2, true)
		self.range = c.range(space, x, y, 200, true)

		W, H = 48, 48
		self.dPivot = c.dPivot(self.sprite.img:getWidth() - W / 2 - 24, self.sprite.img:getHeight() - H / 2)
	end

	self.canvas = canvas
	self.geometry = c.geometry("rect", W, H, "fill", { 1, 0, 1, 1 })

	self.pos = c.pos(x, y)
	self.rotation = c.rotation(0)

	self.collisionbox = c.collisionbox(space, x, y, W, H, -W / 2, -H / 2)

	self.construction = c.construction(type, cost)
end

return Construction
