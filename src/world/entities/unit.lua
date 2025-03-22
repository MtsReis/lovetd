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
	self.team = c.team(2)

	self.state = c.state("idle")
	self.target = c.target()

	if type == "orc" then
		self.geometry.type = "circ"
		self.geometry.colour = { 50 / 255, 148 / 255, 44 / 255, 1 }

		self.sprite = c.sprite("org")

		self.dPivot = c.dPivot(self.sprite.img:getWidth() / 2, self.sprite.img:getHeight() / 2)
		self.movement = c.movement(0, 50, 0, 0)

		self.collisionbox = c.collisionbox(space, x, y, W, H, -W / 2, -H / 2)
		self.selectionbox = c.selectionbox(space, x, y, W, H, -W / 2, -H / 2)

		self.range = c.range(space, x, y, 25, false)
		self.sightRange = c.sightRange(space, x, y, 60)
		self.attack = c.attack(15, 2, 3, 1.5)
		self.stance = c.stance("aggressive")

		self.hp = c.hp(100, 100)
		self.team = c.team(2)

		self.path = c.path(options.path)
	elseif type == "elf" then
		self.geometry = c.geometry("square", W, H, "fill", { 96 / 255, 153 / 255, 181 / 255, 1 })

		self.sprite = c.sprite("elf")

		self.dPivot = c.dPivot(self.sprite.img:getWidth()/2, self.sprite.img:getHeight()/2)
		self.movement = c.movement(0, 80, 0, 0)

		self.collisionbox = c.collisionbox(space, x, y, W, H, -W / 2, -H / 2)
		self.selectionbox = c.selectionbox(space, x, y, W, H, -W / 2, -H / 2)

		self.range = c.range(space, x, y, 100, false)
		self.sightRange = c.sightRange(space, x, y, 175)
		self.attack = c.attack(4, 2, 3, .5, true)
		self.stance = c.stance("aggressive")

		self.hp = c.hp(45, 45)
		self.team = c.team(2)

		self.path = c.path(options.path)
	elseif type == "evil_elf" then
		self.geometry = c.geometry("square", W, H, "fill", { 96 / 255, 153 / 255, 181 / 255, 1 })

		self.sprite = c.sprite("elf_e")

		self.dPivot = c.dPivot(self.sprite.img:getWidth()/2, self.sprite.img:getHeight()/2)
		self.movement = c.movement(0, 0, 0, 0, 80)

		self.collisionbox = c.collisionbox(space, x, y, W, H, -W / 2, -H / 2)
		self.selectionbox = c.selectionbox(space, x, y, W, H, -W / 2, -H / 2)

		self.range = c.range(space, x, y, 100, false)
		self.sightRange = c.sightRange(space, x, y, 175)
		self.attack = c.attack(10, 2, 3, .3, true)
		self.stance = c.stance("aggressive")

		self.hp = c.hp(45, 45)
		self.team = c.team(1)
	end
end

return Unit
