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
	"sidebar_towers",
	"topbar",
}

local UICanvas = love.graphics.newCanvas()

UI.activeP = ""
UI.presentations = {
	PlayScenario = {
		_attr = { sidebar = { width = 118, towerSpots = 3 } },
		canvases = { sidebar_bg = love.graphics.newCanvas() },
	},

	MainMenu = {
		_attr = {  },
		canvases = { upper_layer = love.graphics.newCanvas() },
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

function UI:enable(presentation)
	self.activeP = presentation

	-- Draw base canvases
	self.presentations[self.activeP]:reload()
end

function UI:update(dt)
	if
		type(self.activeP) == "string"
		and self.presentations[self.activeP]
		and self.presentations[self.activeP].update
	then
		self.presentations[self.activeP]:update(dt)
	end
end

function UI.draw()
	love.graphics.draw(UICanvas, 0, 0)
end

function UI:resize(w, h)
	-- Reset canvases
	UICanvas = love.graphics.newCanvas(w, h)
	UI.presentations.PlayScenario.canvases.sidebar_bg =
		love.graphics.newCanvas(UI.presentations.PlayScenario._attr.sidebar.width, h)

	UI.presentations[UI.activeP]:reload(dt)
end

--------------------= MainMenu =--------------------
function UI.presentations.MainMenu:update(dt)
	local screenW = amora.settings.video.w
	local screenH = amora.settings.video.h
	local sidebarX = screenW - self._attr.sidebar.width

	love.graphics.setCanvas(UICanvas)
	love.graphics.clear()

	-------------------- Upper Layer --------------------
	love.graphics.draw(self.canvases.upper_layer, 0, 0)

	love.graphics.setCanvas()
end

function UI.presentations.MainMenu:reload(dt)
	local screenW = amora.settings.video.w
	local screenH = amora.settings.video.h

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
		love.graphics.draw(
			_resources["sidebar_t" .. i],
			(self._attr.sidebar.width - _resources["sidebar_t" .. i]:getWidth()) / 2,
			towerSectionInitialy + towerSpotMaxH * (i - 1) + (towerSpotMaxH - _resources["sidebar_t" .. i]:getHeight()) / 2
		) -- Tower text
	end

	love.graphics.setCanvas()
end

return UI
