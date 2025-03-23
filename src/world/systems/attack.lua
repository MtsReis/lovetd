local STATE = require("world.components").STATE_ENUM
local RangeSystem = tiny.processingSystem(class("RangeSystem"))
local ProjectileEntity = require("world.entities.projectile")

RangeSystem.filter = tiny.requireAny(
	tiny.requireAll("hurtbox", "pos", "team"),
	tiny.requireAll("attack", "pos", "target", "stance", "team", tiny.requireAny("sightRange", "range"))
)

function RangeSystem:process(e, dt)
	local refRange = e.range
	if e.range then
		e.range.shape:moveTo(e.pos.x, e.pos.y)
	end

	if e.sightRange then
		e.sightRange.shape:moveTo(e.pos.x, e.pos.y)
		refRange = e.sightRange
	end

	if e.attack and e.stance == "aggressive" and refRange and e.target then
		refRange.shape:moveTo(e.pos.x, e.pos.y)

		-- Only look for new targets if the curr isn't in range
		if not e.target.targetEntity or not refRange.shape:collidesWith(e.target.targetEntity.collisionbox.shape) or e.target.targetEntity.team == e.team then
			e.target.targetEntity = nil

			-- Iterate over all entities in the world
			for _, otherEntity in pairs(self.entities) do
				-- Only OPPONENTS with collisionbox and hurtbox
				if e ~= otherEntity and e.team ~= otherEntity.team and otherEntity.collisionbox then
					if refRange.shape:collidesWith(otherEntity.collisionbox.shape) then
						e.target.targetEntity = otherEntity
					end
				end
			end
		end
	end
end

local AttackSystem = tiny.processingSystem(class("AttackSystem"))

AttackSystem.filter = tiny.requireAll("pos", "attack", "target", "team", "range", "state")

function AttackSystem:process(e, dt)
	if e.state == STATE.attacking and e.target.targetEntity then
		local currTimer = e.attack.attackCycleTimer - dt
		local type = e.attack.ranged and "ranged" or "melee"

		if currTimer < 0 then
			local targetAngle = e.target.targetEntity.pos - e.pos
			targetAngle = targetAngle:heading()
			-- Resets attack
			e.attack.attackCycleTimer = e.attack.cooldownTime - currTimer
			AttackSystem.world:add(ProjectileEntity(e, type, AttackSystem.world.space, e.target.targetEntity, { rotation = targetAngle }))
		else
			e.attack.attackCycleTimer = currTimer
		end
	end
end

return { attack = AttackSystem, range = RangeSystem }
