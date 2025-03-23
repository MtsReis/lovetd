local h = require("world.entities.handlers.hit")
local collisionSystem = tiny.processingSystem()

--- collisionSystem ---
collisionSystem.filter = tiny.requireAll("pos", "collisionbox")

function collisionSystem:process(e, dt)
	e.collisionbox.shape:moveTo(e.pos.x, e.pos.y)

	if e.rotation then
		e.collisionbox.shape:setRotation(e.rotation)
	end
end

--- hitSystem ---
local hitSystem = tiny.processingSystem()

hitSystem.filter = tiny.requireAll("pos", "rotation", tiny.requireAny("hitbox", "hurtbox"))

function hitSystem:process(e, dt)
	-- Update the positions
	if e.hitbox then
		e.hitbox.shape:moveTo(e.pos.x, e.pos.y)
		e.hitbox.shape:setRotation(e.rotation)

        for _, otherEntity in pairs(self.entities) do
			-- Only entities with hurtbox
			if e ~= otherEntity and otherEntity.hurtbox then
				if e.hitbox.shape:collidesWith(otherEntity.hurtbox.shape) then
                    local invoker = e.invoker

					-- No self harm or FF
					if not e.invoker or not e.invoker.team or not otherEntity.team or e.invoker.team ~= otherEntity.team then
						h.onHit(invoker, e, otherEntity)
					end
				end
			end
		end
	end
	if e.hurtbox then
		e.hurtbox.shape:moveTo(e.pos.x, e.pos.y)
		e.hurtbox.shape:setRotation(e.rotation)
	end


end

--- worldBoundariesSystem ---
local worldBoundariesSystem = tiny.processingSystem()

worldBoundariesSystem.filter = tiny.requireAll("pos", "collisionbox")

function worldBoundariesSystem:process(e, dt)
	if e.pos.x < 0 then
		e.pos.x = 0
	end

	if e.pos.x > collisionSystem.world.properties.width then
		e.pos.x = collisionSystem.world.properties.width
	end

	if e.pos.y < 0 then
		e.pos.y = 0
	end

	if e.pos.y > collisionSystem.world.properties.height then
		e.pos.y = collisionSystem.world.properties.height
	end
end

return { collision = collisionSystem, worldBoundaries = worldBoundariesSystem, hit = hitSystem }
