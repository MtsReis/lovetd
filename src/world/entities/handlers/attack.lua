local c = require("world.components")
local CONDITION = c.CONDITION_ENUM

local handlers = {
	onStopAttacking = function(attacker)
		attacker.attack.attackCycleTimer = 0
	end,
	onDie = function(e, world)
		if e.team then
			if e.team ~= 1 then
				world.player.coins = world.player.coins + world.properties.COINS_PER_KILL
				world.resources.sounds.coin_drop:setVolume(amora.settings.sound.sVolume / 100)
				world.resources.sounds.coin_drop:play()
			end

			-- Converted
			if e[CONDITION.cursed] and e[CONDITION.cursed].cursedBy ~= e.team then
				e.team = c.team(e[CONDITION.cursed].cursedBy)
				e[CONDITION.dead] = nil
				e[CONDITION.cursed] = nil
				e.lifespan = nil

				e.state = c.state("idle")
				e.path = nil

				e.movement.vel.speed = 0
				e.movement.accel.magnitude = 0
				
				if e.hp then
					e.hp.curr = e.hp.max
				end
			end
		end

		-- RIP
		if e == world.player.main_tower then
			world.handlers.onEndScenario(false, 1)
		end
	end,
}

return handlers
