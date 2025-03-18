local HC = require("lib.HC")

local PlayScenario = class("PlayScenario")

local canvas = love.graphics.newCanvas()
local world = tiny.world()
world.space = {
	bump = HC.new(),
	hit = HC.new(),
}

local mapRenderer = {}

function PlayScenario.load(scenarioName)
	scenarioName = scenarioName or "proto"

	PlayScenario.scenario = Persistence.loadScenario(scenarioName)
	state.add(
		require("states.scenario.MapRenderer"),
		"MapRenderer",
		2,
		PlayScenario.scenario.layers,
		PlayScenario.scenario.width,
		PlayScenario.scenario.height,
		{ PlayScenario.scenario.gridW, PlayScenario.scenario.gridH }
	)

	mapRenderer = state.get("MapRenderer")

	-- Update canvas to the dimensions of the map
	canvas = love.graphics.newCanvas(mapRenderer.map.wPixels, mapRenderer.map.hPixels)

	-- World building
	-- Systems
	local entitiesClasses = {
		tower = require("world.entities.tower"),
		unit = require("world.entities.unit"),
		projectile = require("world.entities.projectile"),
	}
	local precachedSystems = {
		require("world/systems/rendering").drawObj,
		require("world/systems/attack").attack,
		require("world/systems/movement").movement,
		require("world/systems/collision").collision,
		require("world/systems/collision").worldBoundaries,
	}

	world.properties = {
		width = mapRenderer.map.w * PlayScenario.scenario.gridW,
		height = mapRenderer.map.h * PlayScenario.scenario.gridH,
	}

	world:add(table.unpack(precachedSystems))
	world:add(
		entitiesClasses.tower(love.graphics.getWidth() / 2, 400, world.space, "archer", canvas),
		entitiesClasses.unit(0, 300, world.space, "orc", canvas),
		entitiesClasses.unit(30, 300, world.space, "human", canvas),
		entitiesClasses.unit(50, 330, world.space, "somethingElse", canvas),
		entitiesClasses.unit(44, 350, world.space, "orc", canvas, { label = "ToughOrc" }),
		entitiesClasses.projectile(44, 350, world.space, "arrow", canvas, { label = "Sanic" })
	)
end

function PlayScenario.enable()
	mapRenderer.cam:lookAt(world.properties.width / 2, world.properties.height / 2)

	-- Set the camera limits
	mapRenderer.cam.maxScale = 5
	mapRenderer.cam.minScale = 0.5

	state.enable("MapRenderer")
end

function PlayScenario.update(_, dt)
	love.graphics.setCanvas(canvas)
	love.graphics.clear()
	world:update(dt)
	love.graphics.setCanvas()

	if love.keyboard.isDown("left") then
		mapRenderer.cam:move(dt * -200, 0)
	elseif love.keyboard.isDown("right") then
		mapRenderer.cam:move(dt * 200, 0)
	end
	if love.keyboard.isDown("up") then
		mapRenderer.cam:move(0, dt * -200)
	elseif love.keyboard.isDown("down") then
		mapRenderer.cam:move(0, dt * 200)
	end

	if love.keyboard.isDown("pageup") then
		mapRenderer.cam:zoom(1 + dt)
	elseif love.keyboard.isDown("pagedown") then
		mapRenderer.cam:zoom(1 / (1 + dt))
		print(mapRenderer.cam.scale)
	end

	-- Force camera limits
	if mapRenderer.cam.scale > mapRenderer.cam.maxScale then
		mapRenderer.cam.scale = mapRenderer.cam.maxScale
	end

	if mapRenderer.cam.scale < mapRenderer.cam.minScale then
		mapRenderer.cam.scale = mapRenderer.cam.minScale
	end
end

function PlayScenario.draw()
	mapRenderer.cam:attach()
	love.graphics.draw(canvas, 0, 0)
	mapRenderer.cam:detach()
end

-- Camera control
function PlayScenario.keypressed(command)
	if command == "drag_screen" then
		mapRenderer.cam.dragging = true
	end
end

function PlayScenario.keyreleased(command)
	print(command)
	if command == "drag_screen" then
		mapRenderer.cam.dragging = false
	end
end

function PlayScenario:mousemoved(x, y, dx, dy, istouch)
	if mapRenderer.cam.dragging then
		dx = -dx * amora.settings.preferences.screenDragSensitivity / mapRenderer.cam.scale
		dy = -dy * amora.settings.preferences.screenDragSensitivity / mapRenderer.cam.scale
		mapRenderer.cam:move(dx, dy)
	end
end

function PlayScenario:wheelmoved(x, y)
	mapRenderer.cam:zoom(1 + y * amora.settings.preferences.wheelSensitivity / 10)
end

function PlayScenario.disable()
	state.disable("MapRenderer")
	PlayScenario.scenario = nil
end

function PlayScenario.unload()
	state.destroy("MapRenderer")
end

return PlayScenario
