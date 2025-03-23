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
local entitiesClasses

local mapRenderer = {}

local _images = {
	hp_container_s = "UI/hp_container_s",
	hp_container_c = "UI/hp_container_c",
	hp_tower = "UI/hp_tower",

	elf = "sprites/elf",
	elf_e = "sprites/elf_e",
	org = "sprites/org",
	org_e = "sprites/org_e",

	tower1 = "sprites/tower1",
	tower2 = "sprites/tower2",
	tower3 = "sprites/tower3",
}

local _sounds = {
	coin_drop = "coin_drop.ogg",
}

local _music = {
	thinking = "bgm1.mp3",
	action = "bgm2.mp3",
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
	entitiesClasses = {
		tower = require("world.entities.tower"),
		unit = require("world.entities.unit"),
		projectile = require("world.entities.projectile"),
		spawner = require("world.entities.spawner"),
		construction = require("world.entities.construction"),
	}

	-- Systems
	local precachedSystems = {
		require("world/systems/lifespan").lifespan,

		require("world/systems/spawner").spawner,
		require("world/systems/construction").construction,

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

	local mwx, mwy = mapRenderer.cam:worldCoords(love.mouse.getPosition())
	world.properties = {
		width = mapRenderer.map.w * PlayScenario.scenario.gridW,
		height = mapRenderer.map.h * PlayScenario.scenario.gridH,
		COINS_PER_KILL = 5,

		cam = mapRenderer.cam,
		mousePos = { x = mwx, y = mwy },
		mouse = world.space.selection:point(mapRenderer.cam:worldCoords(love.mouse.getPosition())),
		selectedEntity = nil,

		paths = PREDEFINED_PATHS[1],
	}

	world.player = {
		coins = 50,
		killed_enemies = 0,
		main_tower = entitiesClasses.tower(910, 180, world.space, "main", canvas),
	}

	-- Aditional assets
	world.resources = {}
	for k, v in pairs(_images) do
		world.resources[k] = love.graphics.newImage(ASSETS_DIR .. v .. ASSETS_EXT)
	end

	world.resources.statsFont = love.graphics.newImageFont(
		"assets/font/love.png",
		" abcdefghijklmnopqrstuvwxyz" .. "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" .. "123456789.,!?-+/():;%&`'*#=[]\""
	)

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
	local spawnerBottom = entitiesClasses.spawner(
		world.properties.width / 2,
		world.properties.height / 2,
		2,
		40,
		nil,
		entitiesClasses.unit,
		PREDEFINED_PATHS[1][1][1][1] - math.random(120, 900),
		PREDEFINED_PATHS[1][1][1][2] - math.random(10, 20),
		world.space,
		"elf",
		canvas,
		{ path = world.properties.paths[1] }
	)

	local spawnerSide = entitiesClasses.spawner(
		world.properties.width / 2,
		world.properties.height / 2,
		2,
		40,
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
		world.player.main_tower,
		spawnerBottom,
		spawnerSide,
		entitiesClasses.tower(world.properties.width / 3, 200, world.space, "tall", canvas),
		entitiesClasses.tower(530, 630, world.space, "face", canvas),
		entitiesClasses.tower(world.properties.width / 2, 400, world.space, "ritual", canvas),
		entitiesClasses.unit(world.properties.width / 3, 300, world.space, "evil_elf", canvas, { label = "Evil Elf" }),
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
			log.debug("Creating tower 1")

			if not world.properties._construction then
				world.properties._construction = entitiesClasses.construction(
					world.properties.width / 2,
					world.properties.height / 2,
					world.space,
					"face",
					canvas
				)

				world:add(world.properties._construction)
			else
				world.properties._construction.lifespan = 0
				world.properties._construction = nil

				world.properties._construction = entitiesClasses.construction(
					world.properties.width / 2,
					world.properties.height / 2,
					world.space,
					"face",
					canvas
				)

				world:add(world.properties._construction)
			end
		end,
		onPressedTower2 = function()
			log.debug("Creating tower 2")

			if not world.properties._construction then
				world.properties._construction = entitiesClasses.construction(
					world.properties.width / 2,
					world.properties.height / 2,
					world.space,
					"tall",
					canvas
				)

				world:add(world.properties._construction)
			else
				world.properties._construction.lifespan = 0
				world.properties._construction = nil

				world.properties._construction = entitiesClasses.construction(
					world.properties.width / 2,
					world.properties.height / 2,
					world.space,
					"tall",
					canvas
				)

				world:add(world.properties._construction)
			end
		end,
		onPressedTower3 = function()
			log.debug("Creating tower 3")

			if not world.properties._construction then
				world.properties._construction = entitiesClasses.construction(
					world.properties.width / 2,
					world.properties.height / 2,
					world.space,
					"ritual",
					canvas
				)

				world:add(world.properties._construction)
			else
				world.properties._construction.lifespan = 0
				world.properties._construction = nil

				world.properties._construction = entitiesClasses.construction(
					world.properties.width / 2,
					world.properties.height / 2,
					world.space,
					"ritual",
					canvas
				)

				world:add(world.properties._construction)
			end
		end,
	})

	world.resources.music.action:setLooping(true)
	world.resources.music.action:setVolume(amora.settings.sound.mVolume / 100)
	world.resources.music.action:play()
end

function PlayScenario.update(_, dt)
	if not amora.pause and not world.player.endScenario then
		-- Update mouse position
		world.properties.mousePos.x, world.properties.mousePos.y = mapRenderer.cam:worldCoords(love.mouse.getPosition())
		world.properties.mouse:moveTo(world.properties.mousePos.x, world.properties.mousePos.y)

		if world.properties._construction then
			love.mouse.setVisible(false)
		else
			love.mouse.setVisible(true)
		end

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

	if world.player.results then
		if world.player.results.endScenarioIn <= 0 then
			world.player.endScenario = true
		else
			world.player.results.endScenarioIn = world.player.results.endScenarioIn - dt
		end
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

		-- Remove construction
		if world.properties._construction then
			world.properties._construction.lifespan = 0
			world.properties._construction = nil
		end
	elseif command == "mouse_command" then
		if world.properties.selectedEntity then
			world.properties.selectedEntity = nil
		end

		-- No world interaction when on sidebar
		if love.mouse.getX() < amora.settings.video.w - UI.presentations.PlayScenario._attr.sidebar.width then
			-- Make construction
			if world.properties._construction then
				if world.player.coins >= world.properties._construction.construction.cost then
					-- If there are collisions
					if not world.properties._construction.construction.blocked then
						world:add(
							entitiesClasses.tower(
								world.properties._construction.pos.x,
								world.properties._construction.pos.y,
								world.space,
								world.properties._construction.construction.type,
								canvas
							)
						)

						world.player.coins = world.player.coins - world.properties._construction.construction.cost

						world.properties._construction.lifespan = 0
						world.properties._construction = nil
					end
				end
			end
		end
	end
end

function PlayScenario:mousemoved(x, y, dx, dy, istouch)
	if mapRenderer.cam.dragging then
		local sidebarW = UI.presentations.PlayScenario._attr.sidebar.width / mapRenderer.cam.scale
		dx = -dx * amora.settings.preferences.screenDragSensitivity / mapRenderer.cam.scale
		dy = -dy * amora.settings.preferences.screenDragSensitivity / mapRenderer.cam.scale

		-- Don't move if it goes out of bounds without debugMode
		if not amora.debugMode then
			-- Forgive me for this mess, I promise I'll make it more readable later (:
			-- cam.x - screen.w/2 / scale (undo scale) + dx < 0 (negative dx will go further to the left that the left border of the camera should) and dx < 0 (only block negative X movement, A.K.A left)
			if
				mapRenderer.cam.x - amora.settings.video.w / mapRenderer.cam.scale / 2 + dx < 0 and dx < 0
				or mapRenderer.cam.x + amora.settings.video.w / mapRenderer.cam.scale / 2 - sidebarW + dx
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

	if mapRenderer.cam.scale < mapRenderer.cam.minScale then
		mapRenderer.cam.scale = mapRenderer.cam.minScale
	end

	-- Fix Camera position after zoom out
	local sidebarW = UI.presentations.PlayScenario._attr.sidebar.width

	-- Left border
	local moveX = -math.min(mapRenderer.cam.x - amora.settings.video.w / mapRenderer.cam.scale / 2, 0)

	-- Right border
	if moveX == 0 then
		moveX = math.min(
			world.properties.width
				- (
					mapRenderer.cam.x
					+ amora.settings.video.w / mapRenderer.cam.scale / 2
					- sidebarW / mapRenderer.cam.scale
				),
			0
		)
	end

	-- Top
	local moveY = -math.min(mapRenderer.cam.y - amora.settings.video.h / mapRenderer.cam.scale / 2, 0)

	-- Bottom
	if moveY == 0 then
		moveY = math.min(
			world.properties.height - (mapRenderer.cam.y + amora.settings.video.h / mapRenderer.cam.scale / 2),
			0
		)
	end

	mapRenderer.cam:move(moveX, moveY)
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
