
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
    GUI.workspaces.ScenarioEditor.activeTiles = ScenarioEditor.tileQuad(GUI.workspaces.ScenarioEditor.tilesets, gameTiles)
    
    local maxWidth = 0
    local maxHeight = 0
    for _, v in pairs(gameTiles) do 
        maxWidth = maxWidth + gameTileSets[v[3]].tileW

        if (gameTileSets[v[3]].tileH > maxHeight) then
            maxHeight = gameTileSets[v[3]].tileH
        end
    end

    GUI.workspaces.ScenarioEditor.tilesCanvas = love.graphics.newCanvas(maxWidth, maxHeight)

    maxWidth = 0
    maxHeight = 0
    for _, v in pairs(GUI.workspaces.ScenarioEditor.tilesets) do
        maxWidth = maxWidth + v.img:getWidth()

        if (v.img:getHeight() > maxHeight) then
            maxHeight = v.img:getHeight()
        end
    end


    GUI.workspaces.ScenarioEditor.tilesetCanvas = love.graphics.newCanvas(maxWidth, maxHeight)
end

function ScenarioEditor.disable()
    state.disable("GUI")
end

function ScenarioEditor.keypressed(key)
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

    local TILESID = 2  -- Index for the needed info in the tiles table
    local TILESNAME = 3

    for k, o in pairs(tileset) do
        tileQuads[k] = {}
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
                    ["tileSetName"] = k
                }
                table.insert(tileQuads[k], quad)
            end
        end
    end

    for i, o in ipairs(tiles) do
        if tileQuads[o[TILESNAME]][o[TILESID]] then
            table.insert(active, tileQuads[o[TILESNAME]][o[TILESID]])
        end
    end
    return active
end

return ScenarioEditor
