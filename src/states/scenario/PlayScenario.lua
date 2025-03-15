local PlayScenario = class("PlayScenario")

local drawQueue = {}
local canvas = love.graphics.newCanvas()

-- Systems
local drawObjectSystem = tiny.processingSystem()
drawObjectSystem.filter = tiny.requireAll("geometry")
function drawObjectSystem:process(e, dt)
	love.graphics.setCanvas(canvas)
	love.graphics.setColor(e.geometry.colour.r, e.geometry.colour.g, e.geometry.colour.b, e.geometry.colour.a)

	local posx = e.pos.x - e.geometry.w / 2
	local posy = e.pos.y - e.geometry.h / 2

	if e.geometry.type and e.geometry.type == "circ" then
		love.graphics.circle("line", posx, posy, e.geometry.w)
	else
		love.graphics.rectangle("fill", posx, posy, e.geometry.w, e.geometry.w)
	end

	love.graphics.setCanvas()
	love.graphics.setColor(1, 1, 1)
end

local towerSystem = tiny.processingSystem()
towerSystem.filter = tiny.requireAll("pos", "tower")
function towerSystem:process(e, dt)
	local foes = tiny.requireAll("position", "velocity", "size")

	love.graphics.setCanvas(canvas)
	love.graphics.setColor(0, 0, 1, 1)

	love.graphics.circle("line", e.pos.x, e.pos.y, e.tower.range)

	love.graphics.setCanvas()
	love.graphics.setColor(1, 1, 1)
end

local world = tiny.world(
	drawObjectSystem,
	towerSystem,
	require("world.entities.tower")(love.graphics.getWidth() / 2, 400),
	require("world.entities.unit")(0, 300)
)

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
end

function PlayScenario.enable()
	state.enable("MapRenderer")
end

function PlayScenario:update(dt)
	world:update(dt)
end

function PlayScenario:draw()
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
