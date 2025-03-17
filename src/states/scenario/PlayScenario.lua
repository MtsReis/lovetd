local PlayScenario = class("PlayScenario")

local canvas = love.graphics.newCanvas()
local world = tiny.world()
world.space = {
	bump = HC.new(),
	hit = HC.new(),
}

function PlayScenario.load(scenarioName)
	scenarioName = scenarioName or "proto"

	PlayScenario.scenario = Persistence.loadScenario(scenarioName)
	state.add(
		require("states.scenario.MapRenderer"),
		"MapRenderer",
		2,
		PlayScenario.scenario.layers,
		PlayScenario.scenario.width,
		{ PlayScenario.scenario.gridW, PlayScenario.scenario.gridH }
	)

	-- World building
	-- Systems
	local entitiesClasses = {
		tower = require("world.entities.tower"),
		unit = require("world.entities.unit"),
	}
	local precachedSystems = {
		require("world/systems/rendering").drawObj,
		require("world/systems/attack").attack,
		require("world/systems/movement").movement,
		require("world/systems/collision").collision,
	}

	world.properties = {
		width = PlayScenario.scenario.width * PlayScenario.scenario.gridW,
	}

	world:add(table.unpack(precachedSystems))
	world:add(
		entitiesClasses.tower(love.graphics.getWidth() / 2, 400, world.space, "archer", canvas),
		entitiesClasses.unit(0, 300, world.space, "orc", canvas),
		entitiesClasses.unit(30, 300, world.space, "human", canvas),
		entitiesClasses.unit(50, 330, world.space, "somethingElse", canvas),
		entitiesClasses.unit(44, 350, world.space, "orc", canvas)
	)
end

function PlayScenario.enable()
	state.enable("MapRenderer")
end

function PlayScenario.update(_, dt)
	love.graphics.setCanvas(canvas)
	love.graphics.clear()
	world:update(dt)
	love.graphics.setCanvas()
end

function PlayScenario.draw()
	love.graphics.draw(canvas, 0, 0)
end

function PlayScenario.disable()
	state.disable("MapRenderer")
	PlayScenario.scenario = nil
end

function PlayScenario.unload()
	state.destroy("MapRenderer")
end

return PlayScenario
