local DebugMode = class("DebugMode")

function DebugMode.load() end

function DebugMode.enable()
	-- Settings for Debug Mode
	log.level = "trace"
end

function DebugMode.update()
	if not amora.debugMode then
		state.disable("Debug")
	end
end

function DebugMode.keypressed(command)
end

function DebugMode.keyreleased(command)
end

function DebugMode.keyhold(command)
end

function DebugMode.disable()
	log.level = "warn"
end

function DebugMode.unload()
end

return DebugMode
