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
		})
	},
	{
		Path({ -- bigMap Path Left
			0,
			1152,
		}, {
			384,
			1152,
		}, {
			384,
			704,
		}, {
			128,
			704,
		}, {
			128,
			160,
		}),

		Path({ -- bigMap Path Right
			1568,
			768,
		}, {
			1248,
			768,
		}, {
			1248,
			608,
		}, {
			704,
			608,
		}),

		Path({ -- bigMap Path Bottom
			864,
			1568,
		}, {
			864,
			1376,
		}, {
			1088,
			1376,
		}, {
			1088,
			1120,
		}),
	},
}
local ASSETS_DIR = "assets/"
local ASSETS_EXT = ".png"
local SOUNDS_DIR = "assets/sounds/"
local MUSIC_DIR = "assets/music/"
local SHADERS_DIR = "world/shaders/"

local BLUR_SHADER_RADIUS = 10

local BLOCKED_TILES = {
	[4] = true,
	[5] = true,
	[6] = true,
	[15] = true,
	[16] = true,
	[17] = true,
	[19] = true,
	--[26] = true,
	--[27] = true,
	--[28] = true,
	--[32] = true,
	[33] = true,
	[34] = true,
	[35] = true,
	--[39] = true,
	[40] = true,
	[41] = true,
	[42] = true,
	[53] = true,
	[54] = true,
	[61] = true,
	[62] = true,
}

local UI
local GameFlow

local PlayScenario = class("PlayScenario")

local canvas = love.graphics.newCanvas()
local HUD_canvas = love.graphics.newCanvas()
local world
local entitiesClasses

local mapRenderer = {}

local _images = {
	hp_container_s = "UI/hp_container_s",
	hp_container_c = "UI/hp_container_c",
	hp_tower = "UI/hp_tower",

	atk = "sprites/atk",
	atk_spd = "sprites/atk_spd",

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
	plan = "plan.mp3",
	action = "action.mp3",
	game_over = "game_over.mp3",
}

local _shader = {
	blur = "blur",
}

local curr_bgm_name
local curr_scenario

function PlayScenario:load(scenarioName, scenarioNumber)
	-- Remove this ;3;
	GameFlow = state.get("GameFlow")
	scenarioNumber = GameFlow.playerLevel

	world = tiny.world()
	world.space = {
		bump = HC.new(), -- Physical collisions
		hit = HC.new(), -- Hit/hurt boxes interactions
		selection = HC.new(), -- For mouse interaction
	}

	if scenarioNumber and scenarioNumber == 1 then
		curr_scenario = 1
		scenarioName = "ShoreBattle"
	elseif scenarioNumber and scenarioNumber == 2 then
		curr_scenario = 2
		scenarioName = "bigMap"
	else
		curr_scenario = 1
		scenarioName = scenarioName or "bigMap"
	end

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
		message = require("world.entities.message"),
		blocker = require("world.entities.blocker"),
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

		require("world/systems/message").message,

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

		paths = PREDEFINED_PATHS[curr_scenario],

		showHP = true,
		nEnemies = curr_scenario == 1 and 80 or 180
	}

	world.player = {
		coins = 50,
		killed_enemies = 0,
	}

	-- Aditional assets
	world.resources = {}
	for k, v in pairs(_images) do
		world.resources[k] = love.graphics.newImage(ASSETS_DIR .. v .. ASSETS_EXT)
	end

	world.resources.statsFont = love.graphics.newImageFont(
		"assets/fonts/love.png",
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

	world.resources.shaders = {}
	for k, v in pairs(_shader) do
		local code = love.filesystem.read(SHADERS_DIR .. v .. ".glsl")
		world.resources.shaders[k] = love.graphics.newShader(code)
	end

	world.resources.shaders.blur:send("radius", BLUR_SHADER_RADIUS)
	world.resources.shaders.blur:send("PI", math.pi)
	world.resources.shaders.blur:send("resolution", { amora.settings.video.w, amora.settings.video.h })

	world:add(table.unpack(precachedSystems))

	if curr_scenario == 1 then
		world:add(
			entitiesClasses.tower(910, 180, world.space, "main", canvas),
			entitiesClasses.tower(world.properties.width / 3, 200, world.space, "tall", canvas),
			entitiesClasses.tower(530, 630, world.space, "face", canvas),
			entitiesClasses.tower(world.properties.width / 2, 400, world.space, "ritual", canvas),

			entitiesClasses.unit(
				world.properties.width / 3,
				300,
				world.space,
				"evil_elf",
				canvas,
				{ label = "Evil Elf" }
			),

			entitiesClasses.unit(845, 165, world.space, "evil_elf", canvas, { label = "Evil Elf 2" }),
			entitiesClasses.unit(910, 230, world.space, "evil_elf", canvas, { label = "Evil Elf 3" }),
			entitiesClasses.unit(965, 165, world.space, "evil_elf", canvas, { label = "Evil Elf 4" }),
			entitiesClasses.unit(870, 250, world.space, "evil_orc", canvas, { label = "Evil Orc" }),
			entitiesClasses.unit(955, 250, world.space, "evil_orc", canvas, { label = "Evil Orc 2" })
		)
	elseif curr_scenario == 2 then
		world:add(
			entitiesClasses.tower(140, 170, world.space, "main", canvas),
			entitiesClasses.tower(717, 618, world.space, "main", canvas),
			entitiesClasses.tower(1100, 1130, world.space, "main", canvas)
		)

		world:add(
			-- Path 1 Left
			entitiesClasses.unit(75, 155, world.space, "evil_elf", canvas, { label = "Evil Elf 2" }),
			entitiesClasses.unit(140, 220, world.space, "evil_elf", canvas, { label = "Evil Elf 3" }),
			entitiesClasses.unit(195, 155, world.space, "evil_elf", canvas, { label = "Evil Elf 4" }),
			entitiesClasses.unit(100, 240, world.space, "evil_orc", canvas, { label = "Evil Orc" }),
			entitiesClasses.unit(185, 240, world.space, "evil_orc", canvas, { label = "Evil Orc 2" }),

			-- Path 2 Right
			entitiesClasses.unit(652, 603, world.space, "evil_elf", canvas, { label = "Evil Elf 2" }),
			entitiesClasses.unit(717, 668, world.space, "evil_elf", canvas, { label = "Evil Elf 3" }),
			entitiesClasses.unit(772, 603, world.space, "evil_elf", canvas, { label = "Evil Elf 4" }),
			entitiesClasses.unit(677, 688, world.space, "evil_orc", canvas, { label = "Evil Orc" }),
			entitiesClasses.unit(762, 688, world.space, "evil_orc", canvas, { label = "Evil Orc 2" }),

			-- Path 3 Bottom
			entitiesClasses.unit(1035, 1115, world.space, "evil_elf", canvas, { label = "Evil Elf 2" }),
			entitiesClasses.unit(1100, 1180, world.space, "evil_elf", canvas, { label = "Evil Elf 3" }),
			entitiesClasses.unit(1155, 1115, world.space, "evil_elf", canvas, { label = "Evil Elf 4" }),
			entitiesClasses.unit(1060, 1200, world.space, "evil_orc", canvas, { label = "Evil Orc" }),
			entitiesClasses.unit(1145, 1200, world.space, "evil_orc", canvas, { label = "Evil Orc 2" })
		)
	end

	-- Add collisionboxes to blockable tiles
	local blockedCoords = {}
	for _, layer in ipairs(PlayScenario.scenario.layers) do
		for i, v in ipairs(layer) do
			if BLOCKED_TILES[v] then
				local yg = (math.ceil(i / PlayScenario.scenario.width) - 1)
				local xg = (i - 1) - yg * PlayScenario.scenario.width

				blockedCoords[yg .. "_" .. xg] =
					{ x = xg, y = yg, w = PlayScenario.scenario.gridW, h = PlayScenario.scenario.gridH }
			end
		end
	end

	for k, v in pairs(blockedCoords) do
		world:add(entitiesClasses.blocker(v.x * v.w, v.y * v.h, world.space, v.w, v.h))
	end

	-- Events
	world.handlers = {
		onEndScenario = function(isWin, endScenarioIn)
			world.player.results = { isWin = isWin, endScenarioIn = endScenarioIn }

			if not isWin then
				world.resources.music[curr_bgm_name]:stop()

				world.resources.music.game_over:setLooping(false)
				world.resources.music.game_over:setVolume(amora.settings.sound.mVolume / 100)
				world.resources.music.game_over:play()
			end

			local text = isWin and "Level Complete! Well done!" or "Defeated, but you'll get it next time!"
			world:add(entitiesClasses.message(text, HUD_canvas))
		end,
	}
end

function PlayScenario.enable()
	curr_bgm_name = PlayScenario.scenario.bgm

	if not world.resources.music[curr_bgm_name] then
		curr_bgm_name = "action"
	end

	mapRenderer.cam:lookAt(world.properties.width / 2, world.properties.height / 2)

	updateCamZoomLimits()

	state.enable("MapRenderer")

	GameFlow = state.get("GameFlow")

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
		onTryAgain = function()
			UI.presentations.PlayScenario._attr.defeat_window = false
			GameFlow.changeScene("gameplay")
		end,
		onNextLevel = function()
			UI.presentations.PlayScenario._attr.victory_window = false
			GameFlow.playerLevel = GameFlow.playerLevel == 1 and 2 or 1
			GameFlow.changeScene("gameplay")
		end,
		onResume = function()
			amora.pause = false
		end,
		onForfeit = function()
			amora.pause = false
			GameFlow.changeScene("main_menu")
		end,
		onStartAction = function()
			for _, v in ipairs(world.properties._spawners[curr_scenario]) do
				world:add(v)
			end

			world.resources.music.plan:stop()

			world.resources.music[curr_bgm_name]:setLooping(true)
			world.resources.music[curr_bgm_name]:setVolume(amora.settings.sound.mVolume / 100)
			world.resources.music[curr_bgm_name]:play()

			UI.presentations.PlayScenario._attr.sidebar.showPlay = false
			UI.presentations.PlayScenario:reload()
		end,
	})

	world.resources.music[curr_bgm_name]:setLooping(true)
	world.resources.music[curr_bgm_name]:setVolume(amora.settings.sound.mVolume / 100)
	world.resources.music.plan:play()

	UI.presentations.PlayScenario._attr.sidebar.showPlay = true
	UI.presentations.PlayScenario:reload()

	--- Additional stuff
	world.properties._spawners = {
		{
			entitiesClasses.spawner(
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
			),
			entitiesClasses.spawner(
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
			),
		},
		{
			-- PATH 1 LEFT
			entitiesClasses.spawner(
				world.properties.width / 2,
				world.properties.height / 2,
				2,
				50,
				nil,
				entitiesClasses.unit,
				PREDEFINED_PATHS[2][1][1][1] - math.random(120, 900),
				PREDEFINED_PATHS[2][1][1][2] - math.random(10, 20),
				world.space,
				"elf",
				canvas,
				{ path = world.properties.paths[1] }
			),
			entitiesClasses.spawner(
				world.properties.width / 2,
				world.properties.height / 2,
				3,
				30,
				nil,
				entitiesClasses.unit,
				PREDEFINED_PATHS[2][1][1][1] - math.random(120, 900),
				PREDEFINED_PATHS[2][1][1][2] - math.random(10, 20),
				world.space,
				"orc",
				canvas,
				{ path = world.properties.paths[1] }
			),
			-- PATH 2 RIGHT
			entitiesClasses.spawner(
				world.properties.width / 2,
				world.properties.height / 2,
				3,
				40,
				nil,
				entitiesClasses.unit,
				PREDEFINED_PATHS[2][2][1][1] + math.random(120, 900),
				PREDEFINED_PATHS[2][2][1][2] + math.random(10, 20),
				world.space,
				"elf",
				canvas,
				{ path = world.properties.paths[2] }
			),
			entitiesClasses.spawner(
				world.properties.width / 2,
				world.properties.height / 2,
				5,
				25,
				nil,
				entitiesClasses.unit,
				PREDEFINED_PATHS[2][2][1][1] + math.random(120, 900),
				PREDEFINED_PATHS[2][2][1][2] + math.random(10, 20),
				world.space,
				"orc",
				canvas,
				{ path = world.properties.paths[2] }
			),
			-- PATH 3 BOTTOM
			entitiesClasses.spawner(
				world.properties.width / 2,
				world.properties.height / 2,
				4,
				25,
				nil,
				entitiesClasses.unit,
				PREDEFINED_PATHS[2][3][1][1] + math.random(10, 20),
				PREDEFINED_PATHS[2][3][1][2] + math.random(120, 900),
				world.space,
				"elf",
				canvas,
				{ path = world.properties.paths[3] }
			),
			entitiesClasses.spawner(
				world.properties.width / 2,
				world.properties.height / 2,
				6,
				10,
				nil,
				entitiesClasses.unit,
				PREDEFINED_PATHS[2][3][1][1] + math.random(10, 20),
				PREDEFINED_PATHS[2][3][1][2] + math.random(120, 900),
				world.space,
				"orc",
				canvas,
				{ path = world.properties.paths[3] }
			),
		},
	}
end

function PlayScenario.update(_, dt)
	if not amora.pause and not world.player.endScenario then
		-- Update mouse position
		world.properties.mousePos.x, world.properties.mousePos.y = mapRenderer.cam:worldCoords(love.mouse.getPosition())
		world.properties.mouse:moveTo(world.properties.mousePos.x, world.properties.mousePos.y)

		if world.properties._construction then
			love.mouse.setVisible(false)
		elseif not mapRenderer.cam.dragging then
			love.mouse.setVisible(true)
		end

		love.graphics.setCanvas(HUD_canvas)
		love.graphics.clear()
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
		mapRenderer.applyShader = world.resources.shaders.blur
		if world.player.results.endScenarioIn <= 0 then
			if (world.player.results.isWin) then
				UI.presentations.PlayScenario._attr.defeat_window = false
				UI.presentations.PlayScenario._attr.victory_window = true
			else
				UI.presentations.PlayScenario._attr.victory_window = false
				UI.presentations.PlayScenario._attr.defeat_window = true
			end
			world.player.endScenario = true
		else
			world.player.results.endScenarioIn = world.player.results.endScenarioIn - dt
			world.resources.shaders.blur:send(
				"radius",
				math.max(0.001, BLUR_SHADER_RADIUS - world.player.results.endScenarioIn * 10)
			)
		end
	elseif amora.pause then
		mapRenderer.applyShader = world.resources.shaders.blur
		world.resources.shaders.blur:send("radius", 10)
	elseif mapRenderer.applyShader then
		mapRenderer.applyShader = nil
	end
end

function PlayScenario.draw()
	if mapRenderer.applyShader then
		love.graphics.setShader(mapRenderer.applyShader)
	end

	mapRenderer.cam:attach()
	love.graphics.draw(canvas, 0, 0)
	mapRenderer.cam:detach()

	love.graphics.setShader()

	love.graphics.draw(HUD_canvas, 0, 0)
end

-- Camera control
function PlayScenario.keypressed(command)
	if command == "drag_screen" then
		love.mouse.setVisible(false)

		-- Remove construction
		if world.properties._construction then
			world.properties._construction.lifespan = 0
			world.properties._construction = nil
		else
			mapRenderer.cam.dragging = true
		end
	elseif command == "toggle_hp" then
		world.properties.showHP = not world.properties.showHP
	elseif command == "pause_game" and not world.player.results then
		amora.pause = not amora.pause
	end
end

function PlayScenario.keyreleased(command)
	if command == "drag_screen" then
		mapRenderer.cam.dragging = false
		love.mouse.setVisible(true)
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
					else
						world:add(entitiesClasses.message("Unable to build here, something is in the way.", HUD_canvas))
					end
				else
					world:add(entitiesClasses.message("Not enough coins!", HUD_canvas))
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

	world.resources.music.plan:stop()
	world.resources.music[curr_bgm_name]:stop()
end

function PlayScenario.unload()
	state.destroy("MapRenderer")

	UI = nil
	GameFlow = nil
	curr_bgm_name = nil

	world.space.bump:resetHash()
	world.space.hit:resetHash()
	world.space.selection:resetHash()
	world.space.bump = nil
	world.space.hit = nil
	world.space.selection = nil
	world.space = nil
	world.properties._spawners = nil

	world.properties = nil
	world.player = nil
	world.resources = nil
	world.handlers = nil

	PlayScenario.scenario = nil
	entitiesClasses = nil

	mapRenderer = nil

	world:clearEntities()
	world:clearSystems()
	world:refresh()

	world = nil
end

function PlayScenario.resize()
	updateCamZoomLimits()
	HUD_canvas = love.graphics.newCanvas() -- Resize canvas
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
