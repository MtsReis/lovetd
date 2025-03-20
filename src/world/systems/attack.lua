local RangeSystem = tiny.processingSystem(class("RangeSystem"))

RangeSystem.filter = tiny.requireAny(
	tiny.requireAll("collisionbox", "pos"),
	tiny.requireAll("attack", "pos", "range", "action", "target", "stance")
)

function RangeSystem:process(e, dt)
	if e.attack and e.stance == "aggressive" and e.range then
		e.range.shape:moveTo(e.pos.x, e.pos.y)

		-- Reset target and action
		e.target.targetEntity = nil
		if e.action.curr.attacking then
			e.action.curr.attacking = nil
		end

		-- Iterate over all entities in the world
		for _, otherEntity in pairs(self.entities) do
			-- Only entities with collisionbox
			if e ~= otherEntity and otherEntity.collisionbox then
				if e.range.shape:collidesWith(otherEntity.collisionbox.shape) then
					e.target.targetEntity = otherEntity

					if e.action then
						e.action.curr.attacking = true
					end
				end
			end
		end
	end
end

local AttackSystem = tiny.processingSystem(class("AttackSystem"))

AttackSystem.filter = tiny.requireAll(tiny.requireAll("attack", "target"))

function AttackSystem:process(e, dt) end

return { attack = AttackSystem, range = RangeSystem }
