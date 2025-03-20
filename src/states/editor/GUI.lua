local Slab = require("lib.Slab")
local GUI = class("GUI")
local SlabDebug = require("lib.Slab.SlabDebug")
local metadata = {
	["name"] = "new scenario",
	["gridW"] = 32,
	["gridH"] = 32,
	["bgm"] = 0,
	["width"] = 36
}
local object = {[1] = {}}
local activeLayer = 1
local fileAction = ''

for i = 1, metadata.width ^ 2 do
	object[1][i] = 0
end

-- CANVASES
local mapArea = love.graphics.newCanvas(metadata.width * metadata.gridH, metadata.width * metadata.gridW)

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
end

function GUI.workspaces.ScenarioEditor:update(dt)
	Slab.DisableDocks({ "Left", "Right", "Bottom" })

	-- DIALOG OPEN SCENARIO
	if fileAction ~= '' then
		local file = Slab.FileDialog({
			AllowMultiSelect = false,
			Type = fileAction,
			Directory = love.filesystem.getSourceBaseDirectory() .. "/src/scenarios",
			Filters = { "*.tds" },
			IncludeParent =  false
		})

		if file.Button ~= "" then
			if file.Button == "OK" then
				if fileAction == "openfile" then
					_, _, fileAction_file = file.Files[1]:find(".*[%/%\\](.*)[.].*")
					local fileAction_file = Persistence.loadScenario(fileAction_file)
					pl.tablex.clear(object)
					object = fileAction_file.layers
					metadata.width = fileAction_file.width
					metadata.gridH = fileAction_file.gridH
					metadata.gridW = fileAction_file.gridW
				end

				if fileAction == "savefile" then
					fileAction_file = file.Files[1]
					fileAction_file = io.open(fileAction_file, 'w')
					fileAction_file:write(GUI.outputString())
					fileAction_file:close()
				end
			end
			fileAction = ''
		end
	end

	-- MAIN MENU BAR
	if Slab.BeginMainMenuBar() then
		if Slab.BeginMenu("File") then
			if Slab.MenuItem("New scenario") then
				-- Create a new file.
			end

			if Slab.MenuItem("Open Scenario") then
				fileAction = 'openfile'
			end

			if Slab.MenuItem("Save Scenario") then
				fileAction = 'savefile'
			end
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

	if self._attr.showTilesetsInfo then
		for x = 0, metadata.width * metadata.gridW, metadata.gridW do
			love.graphics.line(x, 0, x, metadata.width * metadata.gridH)
		end

		for y = 0, metadata.width * metadata.gridH, metadata.gridH do
			love.graphics.line(0, y, metadata.width * metadata.gridW, y)
		end
	end

	love.graphics.setCanvas()
	Slab.Image("img_grid", { Image = mapArea })

	if Slab.IsMouseDown() then
		local mouseX, mouseY = Slab.GetMousePositionWindow()
		GUI.hitboxGrid(mouseX, mouseY, metadata.width, activeLayer)
	end

	Slab.EndWindow()

	-- LAYERS
	Slab.BeginWindow('LayersMainWindow', {Title = "Layers"})

	Slab.BeginListBox('LayerList')
	for i = 1, #object do
		Slab.BeginListBoxItem('Layer_' .. i, {Selected = Selected == i})
		Slab.Text("Layer " .. i)

		if Slab.IsListBoxItemClicked() then
			activeLayer = i
		end

		Slab.EndListBoxItem()
	end
	Slab.EndListBox()

	Slab.Button("+")
	if Slab.IsControlClicked() then
		local index = #object + 1
		object[index] = {}

		for i = 1, metadata.width ^ 2 do
			object[index][i] = 0
		end
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

	-- WARNING DIALOG BOX START
	if Slab.BeginDialog('Warning', {Title = "Warning"}) then
		Slab.Text("If you change this value, the map will reset to a blank state, continue?")

		if Slab.Button("Yes") then
			metadata.width = Slab.GetInputText()
			pl.tablex.clear(object)
			object[1] = {}
			for i = 1, metadata.width ^ 2 do
				object[1][i] = 0
			end
			Slab.CloseDialog()
		end
		Slab.SameLine()
		if Slab.Button("No") then
			Slab.CloseDialog()
		end

		Slab.EndDialog()
	end
	-- WARNING DIALOG BOX END

	Slab.Text("Name:")
	if Slab.Input("Name", { Text = metadata.name, ReturnOnText = false }) then
		metadata.name = Slab.GetInputText()
	end
	Slab.Separator()

	Slab.Text("Map size:")
	if Slab.Input("MapSize", { Text = metadata.width, ReturnOnText = false }) then
		Slab.OpenDialog('Warning')
	end
	Slab.Separator()

	Slab.Text("Tile width:")
	if Slab.Input("GridW", { Text = metadata.gridW, ReturnOnText = false }) then
		metadata.gridW = Slab.GetInputText()
	end
	Slab.Separator()

	Slab.Text("Tile height:")
	if Slab.Input("GridH", { Text = metadata.gridH, ReturnOnText = false }) then
		metadata.gridH = Slab.GetInputText()
	end

	Slab.Text("BGM:")
	if Slab.Input("BGM", { Text = metadata.bgm, ReturnOnText = false }) then
		metadata.bgm = Slab.GetInputText()
	end
	Slab.Separator()

	Slab.EndWindow()

	-- OUTPUT
	Slab.BeginWindow("OutputMainWindow", { Title = "Output", AutoSizeWindow = false })

	Slab.Input("Output", { MultiLine = true, MultiLineW = 50, Text = GUI.outputString(), H = 200, W = 200 })

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

		Slab.Image("img_tile_" .. i, {
			Image = self.tilesCanvas,
			SubW = self.tilesets[o["tileSetName"]].tileW,
			SubH = self.tilesets[o["tileSetName"]].tileH,
			W = self.tilesets[o["tileSetName"]].tileW,
			H = self.tilesets[o["tileSetName"]].tileH,
			SubX = canvasX,
			SubY = 0,
		})
		canvasX = canvasX + self.tilesets[o["tileSetName"]].tileW

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

function GUI.hitboxGrid(mouseX, mouseY, size, layer)
	local WINDOWINTERVAL = 4
	for y = 1, size do
		for x = 1, size do
			if
				(mouseX >= (x - 1) * metadata.gridW + WINDOWINTERVAL and mouseX < x * metadata.gridW + WINDOWINTERVAL)
				and (mouseY >= (y - 1) * metadata.gridH + WINDOWINTERVAL and mouseY < y * metadata.gridH + WINDOWINTERVAL)
			then
				-- To put the information in the correct index we do x + size * (y-1). Example:
				-- If the image is a 3x3 that means that the first tile on the second row would be 4
				-- X = 1 because it's the first iteration in a new row, Y = 2 because it's a new row, Size = 3 because it has 3 tiles in each row
				-- 1 + 3 * (2 - 1) = 4
				index = x + size * (y - 1)
				object[layer][index] = GUI.workspaces.ScenarioEditor._attr.selected.tile
			end
		end
	end
end

function GUI.drawTiles()
	local WS = GUI.workspaces.ScenarioEditor
	local QUAD = "quad"
	local TILENAME = "tileSetName"

	for i, o in ipairs(object) do
		for i2, o2 in ipairs(o) do
			local yg = (math.ceil(i2 / metadata.width) - 1)
			local xg = (i2 - 1) - yg * metadata.width
			if o2 ~= 0 then
				love.graphics.draw(
					WS.tilesets[WS.activeTiles[o2][TILENAME]]["img"],
					WS.activeTiles[o2][QUAD],
					xg * metadata.gridW,
					yg * metadata.gridH
				)
			end
		end
	end
end

function GUI.outputString()
	local finalString = ""

	for k, v in pairs(metadata) do
		finalString = finalString .. k .. ":" .. v .. "\n"
	end

	for i, o in ipairs(object) do
		for i2, o2 in ipairs(o) do
			finalString = finalString .. o2 .. " "
		end
		finalString = finalString .. "\n;\n"
	end

	return finalString
end

return GUI
