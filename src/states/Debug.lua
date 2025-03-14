local DebugMode = class("DebugMode")
lovebird = require("lib.lovebird")

function DebugMode.load() end

function DebugMode.enable()
	-- Settings for Debug Mode
	log.level = "trace"

	pl.pretty.dump(Persistence.loadScenario("proto.tds"))
end

function DebugMode.update()
	if not amora.debugMode then
		state.disable("Debug")
	end

	lovebird.update()
end

function DebugMode.keypressed(command)
	log.info("Pressed the key for the '%(c)s command!" % { c = command })
end

function DebugMode.keyreleased(command)
	log.info("Release the key for the '%(c)s command!" % { c = command })
end

function DebugMode.keyhold(command)
	log.info("Holding the key for the '%(c)s command!" % { c = command })
end

function DebugMode.disable()
	log.level = "warn"
end

function DebugMode.unload()
	lovebird = nil
end

return DebugMode
