local RangeSystem = tiny.processingSystem(class("RangeSystem"))

RangeSystem.filter = tiny.requireAny(
	tiny.requireAll("hurtbox", "pos", "team"),
	tiny.requireAll("attack", "pos", "range", "target", "stance", "team")
)

function RangeSystem:process(e, dt)
	if e.attack and e.stance == "aggressive" and e.range then
		e.range.shape:moveTo(e.pos.x, e.pos.y)

		-- Reset target
		e.target.targetEntity = nil

		-- Iterate over all entities in the world
		for _, otherEntity in pairs(self.entities) do
			-- Only OPPONENTS with collisionbox and hurtbox
			if e ~= otherEntity and e.team ~= otherEntity.team and otherEntity.collisionbox then
				if e.range.shape:collidesWith(otherEntity.collisionbox.shape) then
					e.target.targetEntity = otherEntity
				end
			end
		end
	end
end

local AttackSystem = tiny.processingSystem(class("AttackSystem"))

AttackSystem.filter = tiny.requireAll(tiny.requireAll("attack", "target"))

function AttackSystem:process(e, dt) end

return { attack = AttackSystem, range = RangeSystem }
