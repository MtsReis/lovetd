local UI = class("UI")
local ASSETS_DIR = "assets/UI/"
local ASSETS_EXT = ".png"

local _resources = {
	"sidebar_end",
	"sidebar_ext",
	"sidebar_start_btn",
	"sidebar_towers",

	"sidebar_t1",
	"sidebar_t2",
	"sidebar_t3",

	"sidebar_tower1",
	"sidebar_tower1_hover",
	"sidebar_tower2",
	"sidebar_tower2_hover",
	"sidebar_tower3",
	"sidebar_tower3_hover",

	"topbar",

	"coins",

	"defeat_broken_rook",
	"button_bg",
	"try_again_btn",
	"try_again_btn_pressed",
	"try_again_btn_hover",

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
			defeat_window = false,
			sidebar = { width = 118, towerSpots = 3 },
			coins = { qty = 0, font = love.graphics.newFont(30) },
			buttons = {
				ele_sidebar_tower1 = {
					x = 0,
					y = 0,
					w = 64,
					h = 62,
					state = "",
					active = true,
				},
				ele_sidebar_tower2 = {
					x = 0,
					y = 0,
					w = 64,
					h = 62,
					state = "",
					active = true,
				},
				ele_sidebar_tower3 = {
					x = 0,
					y = 0,
					w = 64,
					h = 62,
					state = "",
					active = true,
				},

				ele_defeat = {
					x = 0,
					y = 0,
					w = 0,
					h = 0,
					state = "",
					active = true,
				},
			},
		},
		canvases = { sidebar_bg = love.graphics.newCanvas(), sidebar_fg = love.graphics.newCanvas() },
		_events = {
			onPress = function(element) end,
			onRelease = function(element)
				if element == "ele_sidebar_tower1" then
					triggerListener("onPressedTower1")
				elseif element == "ele_sidebar_tower2" then
					triggerListener("onPressedTower2")
				elseif element == "ele_sidebar_tower3" then
					triggerListener("onPressedTower3")
				elseif element == "ele_defeat" then
					triggerListener("onTryAgain")
				end
			end,
		},
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
	UI.presentations.PlayScenario.canvases.sidebar_fg = love.graphics.newCanvas()
	UI.presentations.PlayScenario._attr.coins.font = love.graphics.newFont(30)
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
			if type(v.active) ~= "boolean" or v.active then
				if not love.mouse.isDown(1) and v.state == "_pressed" then
					-- Trigger event if exists
					_ = self.presentations[self.activeP]._events.onRelease
						and self.presentations[self.activeP]._events.onRelease(k, v)
				end

				if mx >= v.x and mx <= v.x + v.w and my >= v.y and my <= v.y + v.h then
					v.state = "_hover"

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
	UI.presentations.PlayScenario.canvases.sidebar_fg = love.graphics.newCanvas()

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

	-------------------- SIDEBAR --------------------

	love.graphics.setCanvas(self.canvases.sidebar_fg)
	love.graphics.clear()

	for i = 1, self._attr.sidebar.towerSpots, 1 do
		local resourceLabel = "sidebar_tower" .. i
		local buttonLabel = "ele_sidebar_tower" .. i

		if not self._attr.buttons[buttonLabel].active then
			love.graphics.setColor(0.5, 0.5, 0.5, 1)
		end

		love.graphics.draw(
			_resources[resourceLabel .. self._attr.buttons[buttonLabel].state] or _resources[resourceLabel],
			self._attr.buttons[buttonLabel].x,
			self._attr.buttons[buttonLabel].y
		)
		love.graphics.setColor(1, 1, 1, 1)
	end

	love.graphics.setCanvas(UICanvas)
	love.graphics.clear()

	love.graphics.draw(self.canvases.sidebar_bg, sidebarX, 0)
	love.graphics.draw(self.canvases.sidebar_fg, 0, 0)

	-------------------- TOPBAR --------------------
	love.graphics.draw(_resources.topbar, 0, 0, 0, screenW, 1) -- y scaled

	-------------------- Coins --------------------
	love.graphics.draw(_resources.coins, 10, 10, 0, 0.2, 0.2)
	love.graphics.setFont(self._attr.coins.font)
	love.graphics.print(
		self._attr.coins.qty,
		10 + _resources.coins:getWidth() * 0.2,
		_resources.coins:getHeight() * 0.1
	)

	-------------------- DEFEAT WINDOW --------------------
	if self._attr.defeat_window then
		--- Rook ---
		local hookHScale = screenH / _resources.defeat_broken_rook:getHeight() * 0.75
		local hookW = _resources.defeat_broken_rook:getWidth() * hookHScale
		local hookH = _resources.defeat_broken_rook:getHeight() * hookHScale

		love.graphics.draw(_resources.defeat_broken_rook, screenW / 2 - hookW / 2, 0, 0, hookHScale, hookHScale)

		--- Button ---
		local buttonYSpace = screenH - hookH
		local buttonHScale = buttonYSpace / _resources.button_bg:getHeight() * 0.50

		local buttonW = buttonHScale * _resources.button_bg:getWidth()
		local buttonH = buttonHScale * _resources.button_bg:getHeight()

		love.graphics.draw(
			_resources.button_bg,
			screenW / 2 - buttonW / 2,
			screenH - buttonYSpace,
			0,
			buttonHScale,
			buttonHScale
		)

		local resourceLabel = "try_again_btn"

		self._attr.buttons.ele_defeat.x = screenW / 2 - buttonW / 2
		self._attr.buttons.ele_defeat.y = screenH - buttonYSpace
		self._attr.buttons.ele_defeat.w = self._attr.buttons.ele_defeat.x * buttonHScale
		self._attr.buttons.ele_defeat.h = self._attr.buttons.ele_defeat.y * buttonHScale

		if not self._attr.buttons.ele_defeat.active then
			love.graphics.setColor(0.5, 0.5, 0.5, 1)
		end

		love.graphics.draw(
			_resources[resourceLabel .. self._attr.buttons.ele_defeat.state] or _resources[resourceLabel],
			self._attr.buttons.ele_defeat.x,
			self._attr.buttons.ele_defeat.y,
			0,
			buttonHScale,
			buttonHScale
		)

		--- Message ---
		love.graphics.setColor(205 / 255, 37 / 255, 37 / 255, 0.5)
		love.graphics.rectangle("fill", screenW * 0.40 / 2, hookH / 3, screenW * 0.60, hookW / 4)
	end

	love.graphics.setColor(1, 1, 1, 1)
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
		-- 🫣
		self._attr.buttons["ele_sidebar_tower" .. i].x = sidebarX
			+ (self._attr.sidebar.width - _resources["sidebar_t" .. i]:getWidth()) / 2

		self._attr.buttons["ele_sidebar_tower" .. i].y = towerSectionInitialy
			+ towerSpotMaxH * (i - 1)
			+ (towerSpotMaxH - _resources["sidebar_t" .. i]:getHeight()) / 2

		love.graphics.draw(
			_resources["sidebar_t" .. i],
			self._attr.buttons["ele_sidebar_tower" .. i].x - sidebarX,
			self._attr.buttons["ele_sidebar_tower" .. i].y
		) -- Tower text
	end

	love.graphics.setCanvas()
end

return UI
