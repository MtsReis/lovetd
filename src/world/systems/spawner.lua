local spawnerSystem = tiny.processingSystem()

spawnerSystem.filter = tiny.requireAll("pos", "spawnOverTime")

function spawnerSystem:process(e, dt)
	if e.spawnOverTime.amount <= 0 then
		e.lifespan = 0
	else
		local currTimer = e.spawnOverTime.spawnCycleTimer - dt

		if currTimer < 0 then
			-- Resets timer
			e.spawnOverTime.spawnCycleTimer = e.spawnOverTime.cooldownTime - currTimer

			log.debug(
				"Spawning new entity. %(n)s -> %(s)s. Args: %(a)s"
					% { s = pw(e.spawnOverTime.blueprint), n = e.spawnOverTime.blueprint, a = pw(e.spawnOverTime.args) }
			)
			spawnerSystem.world:add(e.spawnOverTime.blueprint(table.unpack(e.spawnOverTime.args)))
			e.spawnOverTime.amount = e.spawnOverTime.amount - 1
		else
			e.spawnOverTime.spawnCycleTimer = currTimer
		end
	end
end

return { spawner = spawnerSystem }
