local PlayScenario = class("PlayScenario")

function PlayScenario.load(scenarioName)
	scenarioName = scenarioName or "proto"

	PlayScenario.scenario = Persistence.loadScenario(scenarioName)
	state.add(require "states.scenario.MapRenderer", "MapRenderer", 2, PlayScenario.scenario.layers)
end

function PlayScenario.enable()
	state.enable("MapRenderer")
end

function PlayScenario.update() end

function PlayScenario.disable()
	state.disable("MapRenderer")
	PlayScenario.scenario = nil
end

function PlayScenario.unload()
	state.destroy("MapRenderer")
end

return PlayScenario
