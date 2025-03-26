local MELEE_TIMESPAN = 0.8
local c = require("world.components")
local Entity = require("world.entities.entity")
local EFFECT = c.EFFECT_ENUM
local MOD = c.MODIFIER_ENUM

local Projectile = class("Projectile", Entity)

function Projectile:initialize(invoker, type, space, target, options)
	Entity.initialize(self, options)
	local x = options.x or invoker.pos.x or nil
	local y = options.y or invoker.pos.y or nil
	local rotation = options.rotation or invoker.rotation or 0
	local canvas = options.canvas or invoker.canvas or nil
	local dPivot = options.dPivot or c.dPivot(0, 0)
	local lifespan = options.dPivot or c.lifespan(5)

	space = space or options.space or invoker.space or nil

	local w = options.w or 10
	local h = options.h or 20

	self.invoker = c.invoker(invoker)
	self.team = c.team(invoker.team)

	self.canvas = canvas

	self.pos = c.pos(x, y)
	self.rotation = c.rotation(rotation)
	self.geometry = c.geometry("boid", w, h, "fill", { 0.5, 0, 1, 1 })
	self.dPivot = dPivot

	self.movement = c.movement(self.rotation, 500, 0, 2)

	self.hitbox = c.hitbox(space, x, y, h, w, 0, 0)

	self.lifespan = lifespan
	self[EFFECT.pierce] = 0

	if self.invoker[EFFECT.pierce] and self.invoker[EFFECT.pierce] > 0 then
		self[EFFECT.pierce] = self.invoker[EFFECT.pierce]
	end
	
	if self.invoker[MOD.speed] then
		self.movement.vel.speed = self.invoker[MOD.speed]
		self.movement.maxSpeed = self.invoker[MOD.speed]
	end

	if type == "melee" then
		self.lifespan = c.lifespan(MELEE_TIMESPAN)
		self.geometry = nil
		self.sprite = nil
		self.movement = c.movement(self.rotation, 0, 0, 0)

		if target and target.pos then
			self.pos = target.pos
		end
	end
end

return Projectile
