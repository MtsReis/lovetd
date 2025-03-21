local handlers = {
	onStopAttacking = function(attacker)
        attacker.attack.attackCycleTimer = 0
	end,
}

return handlers
