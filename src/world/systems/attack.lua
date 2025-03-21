local RangeSystem = tiny.processingSystem(class("RangeSystem"))

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
		if not e.target.targetEntity or not refRange.shape:collidesWith(e.target.targetEntity.collisionbox.shape) then
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

AttackSystem.filter = tiny.requireAll(tiny.requireAll("attack", "target"))

function AttackSystem:process(e, dt) end

return { attack = AttackSystem, range = RangeSystem }
