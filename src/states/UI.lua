local UI = class("UI")
local ASSETS_DIR = "assets/UI/"
local ASSETS_EXT = ".png"
local ALPHA_SLAB_ONE_FONT_PATH = "assets/fonts/AlfaSlabOne-Regular.ttf"
local MAIN_FONT = love.graphics.newFont(ALPHA_SLAB_ONE_FONT_PATH, 46)
local MAIN_FONT_H = MAIN_FONT:getHeight()

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
	"try_again_btn",
	"try_again_btn_pressed",
	"try_again_btn_hover",

	"pause_wiz",
	"resume_btn",
	"resume_btn_hover",
	"resume_btn_pressed",
	"settings_btn",
	"settings_btn_hover",
	"settings_btn_pressed",
	"main_menu_btn",
	"main_menu_btn_hover",
	"main_menu_btn_pressed",

	"play_btn",
	"play_btn_pressed",
	"play_btn_hover",
	"mm_settings_btn",
	"mm_settings_btn_hover",
	"mm_settings_btn_pressed",
	"mm_tower",
	"mm_bg",
	"red_ray"
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

				ele_main_menu = {
					x = 0,
					y = 0,
					w = 0,
					h = 0,
					state = "",
					active = true,
				},

				ele_resume = {
					x = 0,
					y = 0,
					w = 0,
					h = 0,
					state = "",
					active = true,
				},

				ele_settings = {
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
				elseif element == "ele_resume" then
					triggerListener("onResume")
				elseif element == "ele_main_menu" then
					triggerListener("onForfeit")
				end
			end,
		},
	},

	MainMenu = {
		_attr = {
			buttons = {
				ele_play = {
					x = 0,
					y = 0,
					w = 0,
					h = 0,
					state = "",
					active = true,
				},

				ele_settings = {
					x = 0,
					y = 0,
					w = 0,
					h = 0,
					state = "",
					active = true,
				},
			},
		},
		canvases = { upper_layer = love.graphics.newCanvas() },
		_events = {
			onPress = function(element) end,
			onRelease = function(element)
				if element == "ele_play" then
					triggerListener("onNewGame")
				elseif element == "ele_settings" then
					triggerListener("onSettings")
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
end

function UI.draw()
	love.graphics.draw(UICanvas, 0, 0)
end

function UI:changePresentation(presentation, listeners)
	self.activeP = presentation

	self.eventListeners = listeners or self.eventListeners

	love.graphics.setCanvas(UICanvas)
	love.graphics.clear()

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

	local buttonYSpace = screenH * 0.6 - _resources.play_btn:getHeight() / 2
	local buttonHScale = buttonYSpace / _resources.play_btn:getHeight()

	local buttonW = buttonHScale * _resources.play_btn:getWidth()
	local buttonH = buttonHScale * _resources.play_btn:getHeight()

	self._attr.buttons.ele_settings.x = screenW / 3 - buttonW / 2
	self._attr.buttons.ele_settings.y = screenH - buttonYSpace * 1.2
	self._attr.buttons.ele_settings.w = buttonW
	self._attr.buttons.ele_settings.h = buttonH

	self._attr.buttons.ele_play.x = self._attr.buttons.ele_settings.x
	self._attr.buttons.ele_play.y = self._attr.buttons.ele_settings.y - buttonH * 1.2
	self._attr.buttons.ele_play.w = self._attr.buttons.ele_settings.w
	self._attr.buttons.ele_play.h = self._attr.buttons.ele_settings.h

	love.graphics.setCanvas(self.canvases.upper_layer)
	love.graphics.clear()

	love.graphics.draw(
		_resources["play_btn" .. self._attr.buttons.ele_play.state] or _resources[resourceLabel],
		self._attr.buttons.ele_play.x,
		self._attr.buttons.ele_play.y,
		0,
		buttonHScale,
		buttonHScale
	)
	love.graphics.draw(
		_resources["mm_settings_btn" .. self._attr.buttons.ele_settings.state] or _resources[resourceLabel],
		self._attr.buttons.ele_settings.x,
		self._attr.buttons.ele_settings.y,
		0,
		buttonHScale,
		buttonHScale
	)

	--- Tower ---
	local towerHScale = screenH / _resources.mm_tower:getHeight() * 0.9
	local towerW = _resources.mm_tower:getWidth() * towerHScale
	local towerH = _resources.mm_tower:getHeight() * towerHScale
	local towerY = (screenH - towerH)/2 + (screenH - towerH)/2 * math.sin(love.timer.getTime() / 5)

	love.graphics.draw(_resources.mm_tower, screenW - screenW * .2 - towerW / 2, towerY, 0, towerHScale, towerHScale)

	love.graphics.setCanvas(UICanvas)
	love.graphics.clear()

	--- BG ---
	local rayWScale = screenW / _resources.red_ray:getWidth() * 1.1
	local rayH = _resources.red_ray:getHeight() * rayWScale
	love.graphics.draw(_resources.mm_bg, 0, 0, 0, screenW / _resources.mm_bg:getWidth(), screenH / _resources.mm_bg:getHeight())
	love.graphics.draw(_resources.red_ray, 0, 0, 0, rayWScale, rayWScale)

	local text = "Defence of the Wicked Evil"
	local textW = MAIN_FONT:getWidth(text)

	love.graphics.setFont(MAIN_FONT)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print(text, screenW * .02, rayH / 2, -0.07)
	
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
		local buttonHScale = buttonYSpace / _resources.try_again_btn:getHeight() * 0.50

		local buttonW = buttonHScale * _resources.try_again_btn:getWidth()
		local buttonH = buttonHScale * _resources.try_again_btn:getHeight()

		local resourceLabel = "try_again_btn"

		self._attr.buttons.ele_defeat.x = screenW / 2 - buttonW / 2
		self._attr.buttons.ele_defeat.y = screenH - buttonYSpace
		self._attr.buttons.ele_defeat.w = buttonW
		self._attr.buttons.ele_defeat.h = buttonH

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
		local bgX = screenW * 0.40 / 2
		local bgY = hookH / 3
		local bgW, bgH = screenW * 0.60, hookW / 4
		local text = "Defeat"
		local textW = MAIN_FONT:getWidth(text)

		love.graphics.setColor(205 / 255, 37 / 255, 37 / 255, 0.5)
		love.graphics.rectangle("fill", bgX, bgY, bgW, bgH)

		love.graphics.setFont(MAIN_FONT)
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.print(text, screenW / 2 - textW / 2, bgY + (bgH - MAIN_FONT_H) / 2)
	end

	-- Pause Layer
	if amora.pause then
		local screenW = amora.settings.video.w
		local screenH = amora.settings.video.h

		love.graphics.setCanvas(PauseCanvas)
		love.graphics.clear()

		--- BG Layer ---
		local wizHScale = screenH / _resources.pause_wiz:getHeight()
		local wizWScale = screenW / _resources.pause_wiz:getWidth()

		local wizH = _resources.pause_wiz:getHeight() * wizHScale
		local wizW = _resources.pause_wiz:getWidth() * wizWScale

		love.graphics.draw(_resources.pause_wiz, screenH * 0.01, screenH - wizH, 0, wizWScale, wizHScale)

		--- Buttons ---
		local buttonYSpace = screenH / 6 -- 3 buttons for half screen
		local buttonHScale = buttonYSpace / _resources.main_menu_btn:getHeight()

		local buttonW = buttonHScale * _resources.main_menu_btn:getWidth()
		local buttonH = buttonHScale * _resources.main_menu_btn:getHeight()
		local buttons = self._attr.buttons

		buttons.ele_main_menu.x = screenW / 2 - buttonW / 2
		buttons.ele_main_menu.y = screenH - buttonYSpace
		buttons.ele_main_menu.w = buttonW
		buttons.ele_main_menu.h = buttonH

		buttons.ele_settings.x = buttons.ele_main_menu.x
		buttons.ele_settings.y = buttons.ele_main_menu.y - buttonH
		buttons.ele_settings.w = buttons.ele_main_menu.w
		buttons.ele_settings.h = buttons.ele_main_menu.h

		buttons.ele_resume.x = buttons.ele_settings.x
		buttons.ele_resume.y = buttons.ele_settings.y - buttonH
		buttons.ele_resume.w = buttons.ele_settings.w
		buttons.ele_resume.h = buttons.ele_settings.h

		if not buttons.ele_main_menu.active then
			love.graphics.setColor(0.5, 0.5, 0.5, 1)
		end

		love.graphics.draw(
			_resources["resume_btn" .. buttons.ele_resume.state] or _resources[resourceLabel],
			buttons.ele_resume.x,
			buttons.ele_resume.y,
			0,
			buttonHScale,
			buttonHScale
		)
		love.graphics.draw(
			_resources["settings_btn" .. buttons.ele_settings.state] or _resources[resourceLabel],
			buttons.ele_settings.x,
			buttons.ele_settings.y,
			0,
			buttonHScale,
			buttonHScale
		)
		love.graphics.draw(
			_resources["main_menu_btn" .. buttons.ele_main_menu.state] or _resources[resourceLabel],
			buttons.ele_main_menu.x,
			buttons.ele_main_menu.y,
			0,
			buttonHScale,
			buttonHScale
		)

		love.graphics.setCanvas(UICanvas)
		love.graphics.draw(PauseCanvas)
		love.graphics.setCanvas()
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
