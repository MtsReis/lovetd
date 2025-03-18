local Slab = require("lib.Slab")
local GUI = class("GUI")
local SlabDebug = require("lib.Slab.SlabDebug")
local mapWidth = 36 -- Placeholder
local gridW = 32    -- Placeholder
local gridH = 32    -- Placeholder

GUI.activeWS = ""
GUI.workspaces = {
	ScenarioEditor = { _attr = { showTilesetsInfo = false, selected = { tile = nil } } },
}

function GUI.load(args)
	Slab.Initialize(args)
end

function GUI:enable(workspace)
	self.activeWS = workspace
end

function GUI:update(dt)
	Slab.Update(dt)

	if type(self.activeWS) == "string" and self.workspaces[self.activeWS] and self.workspaces[self.activeWS].update then
		self.workspaces[self.activeWS]:update(dt)
	end
end

function GUI.draw()
	Slab.Draw()
end

function GUI.workspaces.ScenarioEditor:update(dt)
	Slab.DisableDocks({ "Left", "Right", "Bottom" })

	-- MAIN MENU BAR
	if Slab.BeginMainMenuBar() then
		if Slab.BeginMenu("File") then
			if Slab.MenuItem("New scenario") then
				-- Create a new file.
			end

			Slab.MenuItem("Open Scenario")
			Slab.MenuItem("Save Scenario")
			Slab.Separator()
			Slab.MenuItem("Save tile list")
			Slab.Separator()

			if Slab.MenuItem("Quit") then
				amora:exitGracefully()
			end

			Slab.EndMenu()
		end

		if Slab.BeginMenu("Options") then
			if Slab.MenuItemChecked("Show details for tilesets", self._attr.showTilesetsInfo) then
				self._attr.showTilesetsInfo = not self._attr.showTilesetsInfo
			end

			Slab.EndMenu()
		end

        if amora.debugMode then
            SlabDebug.Menu()
        end

		Slab.EndMainMenuBar()
	end

	-- TILESETS
	Slab.BeginWindow("TilesetsMainWindow", { Title = "Tilesets", AutoSizeWindow = false })

	for k, v in pairs(self.tilesets) do
		local imgW, imgH = v.img:getWidth(), v.img:getHeight()
		v.item_tilesetCanvas = love.graphics.newCanvas(imgW, imgH)

		love.graphics.setCanvas(v.item_tilesetCanvas)
		love.graphics.clear()
		love.graphics.draw(v.img, 0, 0)

		if v._guiAttr and v._guiAttr.showInfo or self._attr.showTilesetsInfo then
			for x = 0, imgW, v.tileW do
				love.graphics.line(x, 0, x, imgH)
			end

			for y = 0, imgH, v.tileH do
				love.graphics.line(0, y, imgW, y)
			end
		end

		love.graphics.setCanvas()

		Slab.Image("img_ts_" .. k, { Image = v.item_tilesetCanvas })
		Slab.Separator()
	end

	Slab.EndWindow()

	-- MAP EDITOR
	Slab.BeginWindow(
		"MapEditorMainWindow",
		{ AutoSizeWindow = false, SizerFilter = { "E", "S", "SE" }, X = 0, Y = 0, CanObstruct = false, ConstrainPosition = true }
	)

	local MAPH = mapWidth * gridH
	local MAPW = mapWidth * gridW
	local grid = love.graphics.newCanvas(MAPW, MAPH)
	love.graphics.setCanvas(grid)
	love.graphics.clear()

	for x = 0, mapWidth*gridW, gridW do
		love.graphics.line(x, 0, x, MAPH)
	end

	for y = 0, mapWidth*gridH, gridH do
		love.graphics.line(0, y, MAPW, y)
	end

	love.graphics.setCanvas()
	Slab.Image("img_map", { Image = grid })

	Slab.EndWindow()

	-- MAP METADATA
	Slab.BeginWindow("MapMetadataMainWindow", { Title = "Map Data", AutoSizeWindow = false })

	Slab.Text("File: ")

	Slab.EndWindow()

	-- INFO
	Slab.BeginWindow("AdditionalInfoMainWindow", { Title = "Additional Info", AutoSizeWindow = false })

	Slab.Text(self._attr.selected.tile or "")

	Slab.EndWindow()

	-- TILES
	Slab.BeginWindow("TilesMainWindow", { Title = "Tiles", AutoSizeWindow = false })

	local LIMITCOL = 10
	local QUADWIDTH = 3
	local QUADHEIGHT = 4
	for i, o in ipairs(self.activeTiles) do
		local _, _, imgW, imgH = o["quad"]:getViewport()
		o.item_tileCanvas = love.graphics.newCanvas(imgW, imgH)

		love.graphics.setCanvas(o.item_tileCanvas)
		love.graphics.clear()
		love.graphics.draw(self.tilesets[o["tileSetName"]].img, o["quad"], 0, 0)

		love.graphics.setCanvas()

		Slab.Image("img_tile_" .. i, { Image = o.item_tileCanvas })
		if Slab.IsControlClicked() then
			self._attr.selected.tile = i
		end

		if i % LIMITCOL ~= 0 then
			Slab.SameLine()
		else
			Slab.NewLine()
		end
	end

	Slab.EndWindow()

    -- DEBUG
    if amora.debugMode then
        SlabDebug.Begin()
    end
end

return GUI
