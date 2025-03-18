local Slab = require("lib.Slab")
local GUI = class("GUI")
local SlabDebug = require("lib.Slab.SlabDebug")
local mapWidth = 36 -- Placeholder
local gridW = 32 -- Placeholder
local gridH = 32 -- Placeholder
local object = {}
for i = 1, mapWidth ^ 2 do
	object[i] = 0
end

-- CANVASES
local mapArea = love.graphics.newCanvas(mapWidth * gridH, mapWidth * gridW)

GUI.activeWS = ""
GUI.workspaces = {
	ScenarioEditor = { _attr = { showTilesetsInfo = false, selected = { tile = 0 } } },
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
	--love.graphics.draw(GUI.workspaces.ScenarioEditor.tilesetCanvas)
	
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

	love.graphics.setCanvas(self.tilesetCanvas)
	love.graphics.clear()
	local canvasX = 0

	for k, v in pairs(self.tilesets) do
		local imgW, imgH = v.img:getWidth(), v.img:getHeight()
		love.graphics.draw(v.img, canvasX, 0)

		if v._guiAttr and v._guiAttr.showInfo or self._attr.showTilesetsInfo then
			for x = canvasX, imgW + canvasX, v.tileW do
				love.graphics.line(x, 0, x, imgH)
			end

			for y = 0, imgH, v.tileH do
				love.graphics.line(canvasX, y, imgW + canvasX, y)
			end
		end

		Slab.Image(
			"img_ts_" .. k,
			{
				Image = self.tilesetCanvas,
				SubW = imgW,
				SubH = imgH,
				W = imgW,
				H = imgH,
				SubX = canvasX,
				SubY = 0,
			}
		)

		canvasX = canvasX + imgW
		Slab.Separator()
	end

	love.graphics.setCanvas()

	Slab.EndWindow()

	-- MAP EDITOR
	Slab.BeginWindow("MapEditorMainWindow", {
		AutoSizeWindow = false,
		SizerFilter = { "E", "S", "SE" },
		X = 0,
		Y = 0,
		CanObstruct = false,
		ConstrainPosition = true,
	})

	love.graphics.setCanvas(mapArea)
	love.graphics.clear()

	GUI.drawTiles()

	for x = 0, mapWidth * gridW, gridW do
		love.graphics.line(x, 0, x, mapWidth * gridH)
	end

	for y = 0, mapWidth * gridH, gridH do
		love.graphics.line(0, y, mapWidth * gridW, y)
	end

	love.graphics.setCanvas()
	Slab.Image("img_grid", { Image = mapArea })

	if Slab.IsMouseDown() then
		--print(pl.tablex.values(object))
		local mouseX, mouseY = Slab.GetMousePositionWindow()
		GUI.hitboxGrid(mouseX, mouseY, mapWidth)
	end

	Slab.EndWindow()

	-- MAP METADATA
	Slab.BeginWindow("MapMetadataMainWindow", { Title = "Map Data", AutoSizeWindow = false })

	Slab.Text("File: ")

	Slab.EndWindow()

	-- INFO
	Slab.BeginWindow("AdditionalInfoMainWindow", { Title = "Additional Info", AutoSizeWindow = false })

	Slab.Text(self._attr.selected.tile or "")

	Slab.EndWindow()

	-- PROPERTIES
	Slab.BeginWindow("PropertiesMainWindow", { Title = "Properties" })

	Slab.Text("Map size:")
	if Slab.Input("MapSize", { Text = mapWidth, ReturnOnText = false }) then
		mapWidth = Slab.GetInputText()
	end
	Slab.Separator()

	Slab.Text("Tile width:")
	if Slab.Input("GridW", { Text = gridW, ReturnOnText = false }) then
		gridW = Slab.GetInputText()
	end
	Slab.Separator()

	Slab.Text("Tile height:")
	if Slab.Input("GridH", { Text = gridH, ReturnOnText = false }) then
		gridH = Slab.GetInputText()
	end

	Slab.EndWindow()

	-- Output
	Slab.BeginWindow("OutputMainWindow", { Title = "Output", AutoSizeWindow = false })

	Slab.Input("Output", { MultiLine = true, MultiLineW = 50, Text = pw(object), H = 200, W = 200 })

	Slab.EndWindow()

	-- TILES
	Slab.BeginWindow("TilesMainWindow", { Title = "Tiles", AutoSizeWindow = false })

	local LIMITCOL = 10
	local QUADWIDTH = 3
	local QUADHEIGHT = 4
	canvasX = 0

	love.graphics.setCanvas(self.tilesCanvas)
	love.graphics.clear()
	for i, o in ipairs(self.activeTiles) do
		local _, _, imgW, imgH = o["quad"]:getViewport()
		love.graphics.draw(self.tilesets[o["tileSetName"]].img, o["quad"], canvasX, 0)
		canvasX = canvasX + self.tilesets[o["tileSetName"]].tileW

		Slab.Image("img_tile_" .. i, {
			Image = self.tilesCanvas,
			SubW = self.tilesets[o["tileSetName"]].tileW,
			SubH = self.tilesets[o["tileSetName"]].tileH,
			W = self.tilesets[o["tileSetName"]].tileW,
			H = self.tilesets[o["tileSetName"]].tileH,
			SubX = canvasX,
			SubY = 0,
		})
		if Slab.IsControlClicked() then
			self._attr.selected.tile = i
		end

		if i % LIMITCOL ~= 0 then
			Slab.SameLine()
		else
			Slab.NewLine()
		end
	end

	love.graphics.setCanvas()

	Slab.EndWindow()

	-- DEBUG
	if amora.debugMode then
		SlabDebug.Begin()
	end
end

function GUI.hitboxGrid(mouseX, mouseY, size)
	local WINDOWINTERVAL = 4
	for y = 1, size do
		for x = 1, size do
			if
				(mouseX >= (x - 1) * gridW + WINDOWINTERVAL and mouseX < x * gridW + WINDOWINTERVAL)
				and (mouseY >= (y - 1) * gridH + WINDOWINTERVAL and mouseY < y * gridH + WINDOWINTERVAL)
			then
				-- To put the information in the correct index we do x + size * (y-1). Example:
				-- If the image is a 3x3 that means that the first tile on the second row would be 4
				-- X = 1 because it's the first iteration in a new row, Y = 2 because it's a new row, Size = 3 because it has 3 tiles in each row
				-- 1 + 3 * (2 - 1) = 4
				index = x + size * (y - 1)
				object[index] = GUI.workspaces.ScenarioEditor._attr.selected.tile
			end
		end
	end
end

function GUI.drawTiles()
	local WS = GUI.workspaces.ScenarioEditor
	local QUAD = "quad"
	local TILENAME = "tileSetName"

	for i, o in ipairs(object) do
		local yg = (math.ceil(i / mapWidth) - 1)
		local xg = (i - 1) - yg * mapWidth
		if o ~= 0 then
			love.graphics.draw(
				WS.tilesets[WS.activeTiles[o][TILENAME]]["img"],
				WS.activeTiles[o][QUAD],
				xg * gridW,
				yg * gridH
			)
		end
	end
end

return GUI
