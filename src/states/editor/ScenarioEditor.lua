
local ScenarioEditor = class('ScenarioEditor')

local GUI
local gameTileSets, gameTiles = unpack(require("scenarios.maps"))

function ScenarioEditor.load()
    state.add(
		require("states.editor.GUI"),
		"GUI",
		11
	)

    GUI = state.get("GUI")
end

function ScenarioEditor.enable()
    state.enable("GUI", "ScenarioEditor")
    GUI.workspaces.ScenarioEditor.tilesets = Persistence.loadTilesets()
end

function ScenarioEditor.disable()
    state.disable("GUI")
end

function ScenarioEditor.keypressed(key)
    if key == "console" then
        pd(object)
    end
end

function ScenarioEditor.unload()
    state.destroy("MapRenderer")
end

-- Returns only the quads used in the gameTiles table
-- Returns a table with 2 keys: quad and tileSetName
function ScenarioEditor.tileQuad(tileset, tiles)
    local tileQuads = {}
    local columns = {}
    local rows = {}
    local active = {}

    local tilesId = 2  -- Index for the needed info in the tiles table
    local tilesName = 3

    for i, o in pairs(tileset) do
        tileQuads[i] = {}
        columns = o["img"]:getWidth() / o["tileW"]
        rows = o["img"]:getHeight() / o["tileH"]

        for y = 0, rows - 1 do
            for x = 0, columns - 1 do
                local quad = {
                    ["quad"] = love.graphics.newQuad(
                        x * o["tileW"],
                        y * o["tileH"],
                        o["tileW"],
                        o["tileH"],
                        o["img"]:getDimensions()
                    ),
                    ["tileSetName"] = i
                }
                table.insert(tileQuads[i], quad)
            end
        end
    end

    for i, o in ipairs(tiles) do
        if tileQuads[o[tilesName]][o[tilesId]] then
            table.insert(active, tileQuads[o[tilesName]][o[tilesId]])
        end
    end
    return active
end

return ScenarioEditor

-- function ScenarioEditor.load()
--     scenarioName = scenarioName or "proto"

-- 	ScenarioEditor.scenario = Persistence.loadScenario(scenarioName)
--     -- Tile Set
--     local gameTileSets, gameTiles = unpack(require("scenarios.maps"))
--     tileSets = {}
--     local tileName = {}
--     for i, o in ipairs(gameTiles) do
--         if not tileName[o[3]] then
--             tileName[o[3]] = {}
--             table.insert(tileSets,{
--                 ["tile"] = Persistence.loadTileset(o[3]),
--                 ["sizeX"] = gameTileSets[o[3]].tileW,
--                 ["sizeY"] = gameTileSets[o[3]].tileH,
--                 ["tileSetName"] = o[3]
--             })
--         end
--     end

--     tileSets["info"] = {
--         ["sizeX"] = tileSets[1].sizeX,
--         ["sizeY"] = tileSets[1].sizeY
--     }

--     -- Draw Square
--     sizeSquare = ScenarioEditor.scenario.width
--     --print(ScenarioEditor.scenario.layers[1])
--     ScenarioEditor.tileQuad(tileSets)
--     pd(tileSets)

--     selected = nil
--     object = ScenarioEditor.scenario.layers[2]
--     --[[object = {}
--     for i = 1, sizeSquare^2 do
--         object[i] = 1
--     end
--     pd(tileQuads)]]
-- end

-- function ScenarioEditor.draw()
--     nextX = 0
--     nextY = 0
--     for i, o in ipairs(tileSets) do
--         love.graphics.draw(o["tile"], nextX, 0)
--         nextX = nextX + o["tile"]:getWidth()
--         if o["tile"]:getHeight() > nextY then
--             nextY = o["tile"]:getHeight()
--         end
--     end

--     for y = 1, sizeSquare do
--         for x = 1, sizeSquare do
--             love.graphics.rectangle("line", x * tileSets["info"].sizeX, nextY + y * tileSets["info"].sizeY, tileSets["info"].sizeX, tileSets["info"].sizeY)
--         end
--     end

--     for i, o in ipairs(object) do
--         if o ~= 0 then
--             local yg = (math.ceil(i / sizeSquare) - 1)
--             local xg = (i - 1) - yg * sizeSquare

--             love.graphics.draw(tileSets[tileQuads[o].tileSetNumber].tile, tileQuads[o].quad, (xg+1)*tileSets["info"].sizeX, nextY + (yg+1)*tileSets["info"].sizeY)
--         end
--     end
--     love.graphics.rectangle("fill", love.mouse.getX(), love.mouse.getY(), 20, 20)
-- end

-- function ScenarioEditor:mousepressed(x, y, button)
--     self.hitboxTile(x, y, tileSets)
--     self.hitboxGrid(x, y, sizeSquare, tileSets)
-- end

-- function ScenarioEditor.hitboxTile(mouseX, mouseY, tileset)
--     local width = ""
--     local height = ""
--     local sizeTileX = ""
--     local sizeTileY = ""
--     local rows = ""
--     local columns = ""
--     local lastX = 0
--     local lastAmount = 0

--     for _, i in ipairs(tileset) do
--         width = i["tile"]:getWidth()
--         height = i["tile"]:getHeight()
--         sizeTileX = i.sizeX
--         sizeTileY = i.sizeY
--         columns = width / sizeTileX
--         rows = height / sizeTileY
--         grids = columns * rows

--         for y = 1, height/sizeTileY do
--             for x = 1, width/sizeTileX do
--                 if (mouseX >= lastX + (x-1)*sizeTileX and mouseX < lastX + x*sizeTileX) and (mouseY >= (y-1)*sizeTileY and mouseY < y*sizeTileY) then
--                     selected = lastAmount + x+width/sizeTileX*(y-1)
--                     print(selected)
--                 end
--             end
--         end
--         lastAmount = lastAmount + grids
--         lastX = lastX + width
--     end
-- end

-- function ScenarioEditor.hitboxGrid(mouseX, mouseY, size, tileset)
--     for y = 1, size do
--         for x = 1, size do
--             -- Takes X and multiplies it by the size to get the horizontal pixel (1 * 20 means it's starting at the 20th pixel)
--             -- Same for the end but adds a 1 to get the other side ((1+2)*20 = 40)
--             if (mouseX >= x*tileset[1].sizeX and mouseX < (x+1)*tileset[1].sizeX) and (mouseY >= nextY + y*tileset[1].sizeY and mouseY < nextY + (y+1)*tileset[1].sizeY) then
--                 -- To put the information in the correct index we do x + size * (y-1). Example:
--                 -- If the image is a 3x3 that means that the first tile on the second row would be 4
--                 -- X = 1 because it's the first iteration in a new row, Y = 2 because it's a new row, Size = 3 because it has 3 tiles in each row
--                 -- 1 + 3 * (2 - 1) = 4
--                 index = x+size*(y-1)
--                 object[index] = selected
--             end
--         end
--     end
-- end

-- function ScenarioEditor.tileQuad(tileset)
--     tileQuads = {}
--     local columns = {}
--     local rows = {}
--     for o, i in ipairs(tileset) do
--         columns = i["tile"]:getWidth() / i["sizeX"]
--         rows = i["tile"]:getHeight() / i["sizeY"]

--         for y = 0, rows - 1 do
--             for x = 0, columns - 1 do
--                 local quad = {
--                     ["quad"] = love.graphics.newQuad(
--                         x * i["sizeX"],
--                         y * i["sizeY"],
--                         i["sizeX"],
--                         i["sizeY"],
--                         i["tile"]:getDimensions()
--                     ),
--                     ["tileName"] = i["tileSetName"],
--                     ["tileSetNumber"] = o
--                 }
--                 table.insert(tileQuads, quad)
--                 --pd(tileQuads)
--             end
--         end
--     end
-- end

-- function ScenarioEditor.keypressed(key)
--     if key == "console" then
--         pd(object)
--     end
-- end
