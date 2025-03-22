local handlers = {
	onStopAttacking = function(attacker)
        attacker.attack.attackCycleTimer = 0
	end,
	onDie = function(e, world)
        if e.team and e.team ~= 1 then
			world.player.coins = world.player.coins + world.properties.COINS_PER_KILL
			world.resources.sounds.coin_drop:play()
		end
	end,
}

return handlers
