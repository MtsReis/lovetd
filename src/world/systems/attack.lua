local AttackSystem = tiny.processingSystem(class("AttackSystem"))

AttackSystem.filter =
	tiny.requireAny(tiny.requireAll("collisionbox", "pos"), tiny.requireAll("attack", "pos", "ai", "range", "action"))

function AttackSystem:process(e, dt)
	if e.attack and e.attack.mode == "aggressive" and e.range then
		e.range.shape:moveTo(e.pos.x, e.pos.y)
		if e.action.curr.attacking then
			e.action.curr.attacking = nil
		end

		-- Iterate over all entities in the world
		for _, otherEntity in pairs(self.entities) do
			-- Only entities with collisionbox
			if e ~= otherEntity and otherEntity.collisionbox then
				if e.range.shape:collidesWith(otherEntity.collisionbox.shape) then
					print("Targetable entity found. Distance:", e.pos:dist(otherEntity.pos))

					if e.action then
						e.action.curr.attacking = true
					end
				end
			end
		end
	end
end

return { attack = AttackSystem }
