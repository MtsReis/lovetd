local handlers = {
	onStopAttacking = function(attacker)
		attacker.attack.attackCycleTimer = 0
	end,
	onDie = function(e, world)
		if e.team and e.team ~= 1 then
			world.player.coins = world.player.coins + world.properties.COINS_PER_KILL
			world.resources.sounds.coin_drop:setVolume(amora.settings.sound.sVolume / 100)
			world.resources.sounds.coin_drop:play()
		end

		if e == world.player.main_tower then
			world.handlers.onEndScenario(false, 0.5)
		end
	end,
}

return handlers
