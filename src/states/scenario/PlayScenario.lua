local HC = require("lib.HC")
local Path = require("world.properties.path")
local PREDEFINED_PATHS = {
	{
		Path({
			0,
			736,
		}, {
			544,
			736,
		}, {
			640,
			640,
		}, {
			640,
			448,
		}, {
			672,
			416,
		}, {
			672,
			288,
		}, {
			896,
			288,
		}, {
			896,
			160,
		}),

		Path({
			0,
			736,
		}, {
			320,
			636,
		}, {
			320,
			480,
		}, {
			320,
			192,
		}, {
			832,
			192,
		}),
	},
}
local ASSETS_DIR = "assets/"
local ASSETS_EXT = ".png"
local SOUNDS_DIR = "assets/sounds/"
local MUSIC_DIR = "assets/music/"

local UI

local PlayScenario = class("PlayScenario")

local canvas = love.graphics.newCanvas()
local world = tiny.world()
world.space = {
	bump = HC.new(), -- Physical collisions
	hit = HC.new(), -- Hit/hurt boxes interactions
	selection = HC.new(), -- For mouse interaction
}

local mapRenderer = {}

local _images = {
	hp_container_s = "UI/hp_container_s",
	hp_container_c = "UI/hp_container_c",

	elf = "sprites/elf",
	elf_e = "sprites/elf_e",
	org = "sprites/org",
	org_e = "sprites/org_e",
}

local _sounds = {
	coin_drop = "coin_drop.ogg"
}

local _music = {
	thinking = "bgm1.mp3",
	action = "bgm2.mp3"
}

function PlayScenario:load(scenarioName)
	scenarioName = scenarioName or "ShoreBattle"

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
	local entitiesClasses = {
		tower = require("world.entities.tower"),
		unit = require("world.entities.unit"),
		projectile = require("world.entities.projectile"),
		spawner = require("world.entities.spawner"),
	}

	-- Systems
	local precachedSystems = {
		require("world/systems/lifespan").lifespan,

		require("world/systems/spawner").spawner,

		require("world/systems/rendering").drawObj,
		require("world/systems/movement").movement,
		require("world/systems/collision").collision,
		require("world/systems/collision").worldBoundaries,
		require("world/systems/collision").hit,

		require("world/systems/selection").selection,

		require("world/systems/attack").attack,
		require("world/systems/attack").range,
		require("world/systems/hp").drawHp,

		require("world/systems/state").state,
		require("world/systems/death").death,
		require("world/systems/lifespan").clearReferences,
	}

	world.properties = {
		width = mapRenderer.map.w * PlayScenario.scenario.gridW,
		height = mapRenderer.map.h * PlayScenario.scenario.gridH,
		COINS_PER_KILL = 5,

		cam = mapRenderer.cam,
		mouse = world.space.selection:point(mapRenderer.cam:worldCoords(love.mouse.getPosition())),
		selectedEntity = nil,

		paths = PREDEFINED_PATHS[1],
	}

	world.player = {
		coins = 0,
		killed_enemies = 0
	}

	-- Aditional assets
	world.resources = {}
	for k, v in pairs(_images) do
		world.resources[k] = love.graphics.newImage(ASSETS_DIR .. v .. ASSETS_EXT)
	end

	world.resources.sounds = {}
	for k, v in pairs(_sounds) do
		world.resources.sounds[k] = love.audio.newSource(SOUNDS_DIR .. v, "static")
	end

	world.resources.music = {}
	for k, v in pairs(_music) do
		world.resources.music[k] = love.audio.newSource(MUSIC_DIR .. v, "stream")
	end

	world:add(table.unpack(precachedSystems))

	-- Entities
	local mainTower = entitiesClasses.tower(world.properties.width / 2, 400, world.space, "archer", canvas)
	local spawnerBottom = entitiesClasses.spawner(
		world.properties.width / 2,
		world.properties.height / 2,
		5,
		2,
		nil,
		entitiesClasses.unit,
		PREDEFINED_PATHS[1][1][1][1] - math.random(120, 900),
		PREDEFINED_PATHS[1][1][1][2] - math.random(10, 20),
		world.space,
		"orc",
		canvas,
		{ path = world.properties.paths[1] }
	)

	local spawnerSide = entitiesClasses.spawner(
		world.properties.width / 2,
		world.properties.height / 2,
		5,
		2,
		nil,
		entitiesClasses.unit,
		PREDEFINED_PATHS[1][2][1][1] - math.random(120, 900),
		PREDEFINED_PATHS[1][2][1][2] - math.random(10, 20),
		world.space,
		"orc",
		canvas,
		{ path = world.properties.paths[2] }
	)
	world:add(
		mainTower,
		spawnerBottom,
		spawnerSide,
		entitiesClasses.tower(world.properties.width / 3, 200, world.space, "archer", canvas),
		entitiesClasses.unit(world.properties.width / 3, 300, world.space, "evil_elf", canvas, { label = "Evil Elf" }),
		entitiesClasses.tower(world.properties.width * 0.75, world.properties.height / 5, world.space, "archer", canvas),
		entitiesClasses.unit(
			PREDEFINED_PATHS[1][1][1][1] + math.random(-130, 130),
			PREDEFINED_PATHS[1][1][1][2] + math.random(-130, 130),
			world.space,
			"elf",
			canvas,
			{ label = "Elf", path = world.properties.paths[1] }
		),
		entitiesClasses.unit(
			PREDEFINED_PATHS[1][1][1][1] + math.random(-130, 130),
			PREDEFINED_PATHS[1][1][1][2] + math.random(-130, 130),
			world.space,
			"orc",
			canvas,
			{ label = "ToughOrc", path = world.properties.paths[1] }
		)
	)
end

function PlayScenario.enable()
	mapRenderer.cam:lookAt(world.properties.width / 2, world.properties.height / 2)

	updateCamZoomLimits()

	state.enable("MapRenderer")

	UI = state.get("UI")
	UI:changePresentation("PlayScenario", {
		onPressedTower1 = function()
			print("Create tower 1")
		end,
		onPressedTower2 = function()
			print("Create tower 2")
		end,
		onPressedTower3 = function()
			print("Create tower 3")
		end,
	})

	world.resources.music.action:setLooping(true)
	world.resources.music.action:play()
end

function PlayScenario.update(_, dt)
	if not amora.pause then
		love.graphics.setCanvas(canvas)
		love.graphics.clear()
		world:update(dt)
		love.graphics.setCanvas()

		-- Force camera limits
		if not amora.debugMode then
			if mapRenderer.cam.scale > mapRenderer.cam.maxScale then
				mapRenderer.cam.scale = mapRenderer.cam.maxScale
			end

			if mapRenderer.cam.scale < mapRenderer.cam.minScale then
				mapRenderer.cam.scale = mapRenderer.cam.minScale
			end
		end

		-- Update UI values
		UI.presentations.PlayScenario._attr.coins.qty = world.player.coins
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
		love.mouse.setVisible(false)
	end
end

function PlayScenario.keyreleased(command)
	if command == "drag_screen" then
		mapRenderer.cam.dragging = false
		love.mouse.setVisible(true)
	end
end

function PlayScenario:mousemoved(x, y, dx, dy, istouch)
	if mapRenderer.cam.dragging then
		dx = -dx * amora.settings.preferences.screenDragSensitivity / mapRenderer.cam.scale
		dy = -dy * amora.settings.preferences.screenDragSensitivity / mapRenderer.cam.scale

		-- Don't move if it goes out of bounds without debugMode
		if not amora.debugMode then
			-- Forgive me for this mess, I promise I'll make it more readable later (:
			-- cam.x - screen.w/2 / scale (undo scale) + dx < 0 (negative dx will go further to the left that the left border of the camera should) and dx < 0 (only block negative X movement, A.K.A left)
			if
				mapRenderer.cam.x - amora.settings.video.w / mapRenderer.cam.scale / 2 + dx < 0 and dx < 0
				or mapRenderer.cam.x + amora.settings.video.w / mapRenderer.cam.scale / 2 + dx
						> world.properties.width
					and dx > 0
			then
				dx = 0
			end

			if
				mapRenderer.cam.y - amora.settings.video.h / mapRenderer.cam.scale / 2 + dy < 0 and dy < 0
				or mapRenderer.cam.y + amora.settings.video.h / mapRenderer.cam.scale / 2 + dy
						> world.properties.height
					and dy > 0
			then
				dy = 0
			end
		end

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

function PlayScenario.resize()
	updateCamZoomLimits()
end

---------------------------------------------------

function updateCamZoomLimits()
	-- Set the camera limits
	mapRenderer.cam.maxScale = 5

	local worldWProportion = amora.settings.video.w / world.properties.width
	local worldHProportion = amora.settings.video.h / world.properties.height

	mapRenderer.cam.minScale = math.max(worldWProportion, worldHProportion)
end

return PlayScenario
