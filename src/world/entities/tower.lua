local c = require("world.components")
local Entity = require("world.entities.entity")
local EFFECT = c.EFFECT_ENUM
local MOD = c.MODIFIER_ENUM

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
	self.range = c.range(space, x, y, 130, true)
	self.target = c.target()

	self.team = c.team(1)

	if type == "face" then
		W, H = 28, 28
		self.sprite = c.sprite("tower1", .5, .5)
		self.dPivot = c.dPivot(self.sprite.img:getWidth()/2, self.sprite.img:getHeight() - H / 2 - 8)

		self.hp = c.hp(200, 200)

		self.selectionbox = c.selectionbox(space, x, y, W, H, -W / 2, -H / 2)
		self.collisionbox = c.collisionbox(space, x, y, W, H, -W / 2, -H / 2)
		self.hurtbox = c.hurtbox(space, x, y, W - 5, H - 5, -W / 2, -H / 2)

		self.attack = c.attack(3, 2, 3, 0.08, true)
		self.range = c.range(space, x, y, 130)
	elseif type == "tall" then
		W, H = 30, 30

		self.sprite = c.sprite("tower2", .5, .5)
		self.dPivot = c.dPivot(self.sprite.img:getWidth()/2, self.sprite.img:getHeight() - H / 2 - 8)

		self.hp = c.hp(200, 200)

		self.selectionbox = c.selectionbox(space, x, y, W, H, -W / 2, -H / 2)
		self.collisionbox = c.collisionbox(space, x, y, W, H, -W / 2, -H / 2)
		self.hurtbox = c.hurtbox(space, x, y, W - 5, H - 5, -W / 2, -H / 2)

		self.attack = c.attack(25, 2, 3, 2, true)
		self.range = c.range(space, x, y, 330)

		self[EFFECT.pierce] = c[EFFECT.pierce](3)
		self[MOD.speed] = c[MOD.speed](1000)
	elseif type == "ritual" then
		W, H = 48, 48

		self.sprite = c.sprite("tower3")
		self.dPivot = c.dPivot(self.sprite.img:getWidth() - W / 2 - 12, self.sprite.img:getHeight() - H / 2 + 7)

		self.hp = c.hp(200, 200)

		self.selectionbox = c.selectionbox(space, x, y, W, H, -W / 2, -H / 2)
		self.collisionbox = c.collisionbox(space, x + 15, y + 10, W - 30, H - 20, -W / 2, -H / 2)
		self.hurtbox = c.hurtbox(space, x, y, W, H, -W / 2, -H / 2)

		self.attack = c.attack(25, 2, 3, 2, true)
		self.range = c.range(space, x, y, 200)

		self[EFFECT.curse] = c[EFFECT.curse](20)
	elseif type == "main" then
		W, H = 48, 48

		self.main = true

		self.sprite = c.sprite("tower4")
		self.dPivot = c.dPivot(self.sprite.img:getWidth() - W / 2 - 24, self.sprite.img:getHeight() - H / 2)

		self.hp = c.hp(700, 700)

		self.selectionbox = c.selectionbox(space, x, y, W, H, -W / 2, -H / 2)
		self.collisionbox = c.collisionbox(space, x, y, W, H, -W / 2, -H / 2)
		self.hurtbox = c.hurtbox(space, x, y, W - 20, H - 20, -W / 2, -H / 2)

		self.attack = c.attack(25, 2, 3, 2, true)
		self.range = c.range(space, x, y, 200, false)
	end
end

return Tower
