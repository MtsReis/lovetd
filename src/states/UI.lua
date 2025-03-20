local UI = class("UI")
local ASSETS_DIR = "assets/UI/"
local ASSETS_EXT = ".png"

local _resources = {
	"sidebar_end",
	"sidebar_ext",
	"sidebar_start_btn",
	"sidebar_t1",
	"sidebar_t2",
	"sidebar_t3",
	"sidebar_t1_tower",
	"sidebar_t1_tower_hover",
	"sidebar_t2_tower",
	"sidebar_t3_tower",
	"sidebar_towers",
	"topbar",

	"pause",

	"new_game_btn",
	"new_game_btn_pressed",
	"new_game_btn_hover",
	"options_btn",
	"options_btn_pressed",
	"options_btn_hover",
}

local function triggerListener(name, ...)
	_ = UI.eventListeners[name] and UI.eventListeners[name](...)
end

local UICanvas = love.graphics.newCanvas()
local PauseCanvas = love.graphics.newCanvas()

UI.activeP = "" -- Active presentation
UI.eventListeners = {}
UI.presentations = {
	PlayScenario = {
		_attr = {
			sidebar = { width = 118, towerSpots = 3 },
			buttons = {},
		},
		canvases = { sidebar_bg = love.graphics.newCanvas() },
		_events = {},
	},

	MainMenu = {
		_attr = {
			buttons = {
				ele_new_game_btn = {
					x = 0,
					y = 0,
					w = 200,
					h = 50,
					state = "",
				},
				ele_options_btn = {
					x = 0,
					y = 0,
					w = 200,
					h = 50,
					state = "",
				},
			},
		},
		canvases = { upper_layer = love.graphics.newCanvas() },
		_events = {
			onPress = function(element)
				if element == "ele_new_game_btn" then
				end
			end,
			onRelease = function(element)
				if element == "ele_new_game_btn" then
					triggerListener("onNewGame")
				elseif element == "ele_options_btn" then
					triggerListener("onOptions")
				end
			end,
		},
	},
}

function UI.load()
	-- Load image files
	local resources = {}
	for _, v in ipairs(_resources) do
		resources[v] = love.graphics.newImage(ASSETS_DIR .. v .. ASSETS_EXT)
	end

	_resources = resources

	-- Set attrs
	UI.presentations.PlayScenario._attr.sidebar.endH = _resources.sidebar_end:getHeight()
	UI.presentations.PlayScenario.canvases.sidebar_bg =
		love.graphics.newCanvas(UI.presentations.PlayScenario._attr.sidebar.width, amora.settings.video.h)
end

function UI:enable(presentation, listeners)
	self:changePresentation(presentation, listeners)
end

function UI:update(dt)
	if
		type(self.activeP) == "string"
		and self.presentations[self.activeP]
		and self.presentations[self.activeP].update
	then
		-- Update active elements
		local mx, my = love.mouse.getPosition()
		for k, v in pairs(self.presentations[self.activeP]._attr.buttons) do
			if not love.mouse.isDown(1) and v.state == "_pressed" then
				-- Trigger event if exists
				_ = self.presentations[self.activeP]._events.onRelease
					and self.presentations[self.activeP]._events.onRelease(k, v)
			end

			if mx >= v.x and mx <= v.x + v.w and my >= v.y and my <= v.y + v.h then
				v.state = "_hover"
				if self.activeP == "PlayScenario" then
					pd(v)
					pd({mx, my})
				end

				if love.mouse.isDown(1) then
					if v.state ~= "_pressed" then
						v.state = "_pressed"

						-- Trigger event if exists
						_ = self.presentations[self.activeP]._events.onPress
							and self.presentations[self.activeP]._events.onPress(k, v)
					end
				end
			else
				v.state = ""
			end
		end

		self.presentations[self.activeP]:update(dt)
	end

	-- Pause Layer
	if amora.pause then
		love.graphics.setCanvas(PauseCanvas)
		love.graphics.clear()

		--- Upper Layer ---
		love.graphics.draw(
			_resources.pause,
			amora.settings.video.w / 2 - _resources.pause:getWidth() / 2,
			amora.settings.video.h / 2 - _resources.pause:getHeight() / 2
		)

		love.graphics.setCanvas(UICanvas)
		love.graphics.draw(PauseCanvas)
		love.graphics.setCanvas()
	end
end

function UI.draw()
	love.graphics.draw(UICanvas, 0, 0)
end

function UI:changePresentation(presentation, listeners)
	self.activeP = presentation

	self.eventListeners = listeners or self.eventListeners

	-- Draw base canvases
	self.presentations[self.activeP]:reload()
end

function UI:resize(w, h)
	-- Reset canvases
	UICanvas = love.graphics.newCanvas(w, h)
	PauseCanvas = love.graphics.newCanvas(w, h)

	UI.presentations.PlayScenario.canvases.sidebar_bg =
		love.graphics.newCanvas(UI.presentations.PlayScenario._attr.sidebar.width, h)

	UI.presentations[UI.activeP]:reload(dt)
end

--------------------= MainMenu =--------------------
function UI.presentations.MainMenu:update(dt)
	local screenW = amora.settings.video.w
	local screenH = amora.settings.video.h

	-- Update elements
	local buttonsInitialPos = {
		screenW / 2 - _resources.new_game_btn:getWidth() / 2,
		screenH * 0.6 - _resources.new_game_btn:getHeight() / 2,
	}

	-------------------- Upper Layer --------------------
	self._attr.buttons.ele_new_game_btn.x = buttonsInitialPos[1]
	self._attr.buttons.ele_new_game_btn.y = buttonsInitialPos[2]

	self._attr.buttons.ele_options_btn.x = buttonsInitialPos[1]
	self._attr.buttons.ele_options_btn.y = buttonsInitialPos[2] + _resources.new_game_btn:getHeight() + 20

	love.graphics.setCanvas(self.canvases.upper_layer)
	love.graphics.clear()
	love.graphics.draw(
		_resources["new_game_btn" .. self._attr.buttons.ele_new_game_btn.state],
		self._attr.buttons.ele_new_game_btn.x,
		self._attr.buttons.ele_new_game_btn.y
	)
	love.graphics.draw(
		_resources["options_btn" .. self._attr.buttons.ele_options_btn.state],
		self._attr.buttons.ele_options_btn.x,
		self._attr.buttons.ele_options_btn.y
	)

	love.graphics.setCanvas(UICanvas)
	love.graphics.draw(self.canvases.upper_layer, 0, 0)

	love.graphics.setCanvas()
end

function UI.presentations.MainMenu:reload(dt)
	local screenW = amora.settings.video.w
	local screenH = amora.settings.video.h

	self.canvases.upper_layer = love.graphics.newCanvas()

	love.graphics.setCanvas()
end

--------------------= PlayScenario =--------------------

function UI.presentations.PlayScenario:update(dt)
	local screenW = amora.settings.video.w
	local screenH = amora.settings.video.h
	local sidebarX = screenW - self._attr.sidebar.width

	love.graphics.setCanvas(UICanvas)
	love.graphics.clear()

	-------------------- SIDEBAR --------------------
	love.graphics.draw(self.canvases.sidebar_bg, sidebarX, 0)

	-------------------- TOPBAR --------------------
	love.graphics.draw(_resources.topbar, 0, 0, 0, screenW, 1) -- y scaled

	love.graphics.setCanvas()
end

function UI.presentations.PlayScenario:reload(dt)
	local screenW = amora.settings.video.w
	local screenH = amora.settings.video.h
	local sidebarX = screenW - self._attr.sidebar.width

	-------------------- SIDEBAR --------------------
	love.graphics.setCanvas(self.canvases.sidebar_bg)
	love.graphics.clear()

	local sb_endH = self._attr.sidebar.endH
	love.graphics.draw(_resources.sidebar_end, 0, 0)
	love.graphics.draw(_resources.sidebar_ext, 0, sb_endH, 0, 1, screenH - sb_endH * 2) -- y scaled
	love.graphics.draw(_resources.sidebar_end, 0, screenH, 0, 1, -1) -- Flipped scale

	love.graphics.draw(
		_resources.sidebar_towers,
		(self._attr.sidebar.width - _resources.sidebar_towers:getWidth()) / 2,
		sb_endH
	) -- Tower text

	local towerSectionInitialy = sb_endH + _resources.sidebar_towers:getHeight() + 3
	local towerSectionH = screenH - towerSectionInitialy - sb_endH
	local towerSpotMaxH = towerSectionH / self._attr.sidebar.towerSpots
	for i = 1, self._attr.sidebar.towerSpots, 1 do
		local iterationTower = "sidebar_t" .. i
		self._attr.buttons["ele_" .. iterationTower .. "_tower"] = {
			x = (self._attr.sidebar.width - _resources[iterationTower .. "_tower"]:getWidth()) / 2,
			y = towerSectionInitialy
				+ towerSpotMaxH * (i - 1)
				+ (towerSpotMaxH - _resources[iterationTower .. "_tower"]:getHeight()) / 2,
			w = 64,
			h = 62,
			state = ""
		}

		love.graphics.draw(
			_resources[iterationTower],
			self._attr.buttons["ele_" .. iterationTower .. "_tower"].x,
			self._attr.buttons["ele_" .. iterationTower .. "_tower"].y
		) -- Tower text
		love.graphics.draw(
			_resources[iterationTower .. "_tower"],
			self._attr.buttons["ele_" .. iterationTower .. "_tower"].x,
			self._attr.buttons["ele_" .. iterationTower .. "_tower"].y
		) -- Tower image
	end

	self._events = {
		onPress = function(element)
			for k, v in pairs(self._attr.buttons) do
				if element == k then
				end
			end
		end,
		onRelease = function(element)
			for k, v in pairs(self._attr.buttons) do
				if element == k then
					print("clicou")
				end
			end
		end,
	}

	pd(self._events)
	pd(self._attr.buttons)
	love.graphics.setCanvas()
end

return UI
