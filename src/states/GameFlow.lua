local GameFlow = class("GameFlow")

function GameFlow.load()
	state.add(require("states.scenario.PlayScenario"), "PlayScenario", 3)
end

function GameFlow.enable()
	state.enable("UI", "PlayScenario")
	state.enable("PlayScenario")
end

return GameFlow
