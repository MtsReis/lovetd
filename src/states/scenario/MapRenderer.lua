local Camera = require("lib.camera")
local I_TILESET_NAME = 3
local MAP_BG_COLOUR = { 0.5, 0.5, 0.5, 1 }

local mapCanvas

local MapRenderer = class("MapRenderer")
local gameTileSets, gameTiles = unpack(require("scenarios.maps"))
local loadedTiles

function MapRenderer.load(layers, mapW, mapH, tileSize)
	mapCanvas = love.graphics.newCanvas()
	loadedTiles = {}
	MapRenderer.map = { layers = {}, w = 0, h = 0, gridW = 0, gridH = 0 }

	-----

	local precache = { tiles = {}, tilesets = {} }
	local hash = { tiles = {}, tilesets = {} }

	for _, layer in ipairs(layers) do
		for _, v in ipairs(layer) do
			if v ~= 0 then
				if not gameTiles[v] then
					log.fatal("Failed to load required tile '%(t)s'" % { t = v })
					amora.ouch()
				end

				-- Look for distinct tile ids
				if not hash.tiles[v] then
					table.insert(precache.tiles, v)
					hash.tiles[v] = true

					-- Save distinct tilesets required by the tiles
					local tileset_name = gameTiles[v][I_TILESET_NAME]
					if not gameTileSets[tileset_name] then
						log.fatal("Failed to load required tileset '%(ts)s'" % { ts = tileset_name })
						amora.ouch()
					end

					if not hash.tilesets[tileset_name] then
						table.insert(precache.tilesets, tileset_name)
						hash.tilesets[tileset_name] = true
					end
				end
			end
		end
	end

	log.debug("Required tiles for scenario: %(tl)s" % { tl = pw(precache.tiles) })
	log.info("Precaching %(ts)s" % { ts = pw(precache.tilesets) })

	local tileQuads = {}
	local tilesetImages = {}

	-- Load all quads from the tilesets in the tileQuads
	for _, t in ipairs(precache.tilesets) do
		tileQuads[t] = {}
		tilesetImages[t] = Persistence.loadTilesetImage(t)

		local currTileset = gameTileSets[t]

		-- Number of tiles
		local tilesetWidth = tilesetImages[t]:getWidth() / currTileset.tileW
		local tilesetHeight = tilesetImages[t]:getHeight() / currTileset.tileH

		-- Create Quads for each tile
		for y = 0, tilesetHeight - 1 do
			for x = 0, tilesetWidth - 1 do
				local quad = love.graphics.newQuad(
					x * currTileset.tileW,
					y * currTileset.tileH,
					currTileset.tileW,
					currTileset.tileH,
					tilesetImages[t]:getDimensions()
				)
				table.insert(tileQuads[t], quad)
			end
		end
	end

	MapRenderer.map.layers = layers
	MapRenderer.map.gridW = tileSize[1]
	MapRenderer.map.gridH = tileSize[2]
	MapRenderer.map.w = mapW
	MapRenderer.map.h = mapH

	MapRenderer.map.wPixels = MapRenderer.map.w * MapRenderer.map.gridW
	MapRenderer.map.hPixels = MapRenderer.map.h * MapRenderer.map.gridH

	loadedTiles.quads = tileQuads
	loadedTiles.tilesetImages = tilesetImages

	MapRenderer.cam = Camera(0, 0)

	mapCanvas = love.graphics.newCanvas(MapRenderer.map.wPixels, MapRenderer.map.hPixels)
end

function MapRenderer.enable() end

function MapRenderer.update()
	love.graphics.setCanvas(mapCanvas)
	love.graphics.clear(MAP_BG_COLOUR)

	for _, layer in ipairs(MapRenderer.map.layers) do
		for i, tile in ipairs(layer) do
			if tile ~= 0 then
				local currTile = gameTiles[tile]
				local currTilePosId = currTile[2]
				local currTileset = currTile[3]

				local yg = (math.ceil(i / MapRenderer.map.w) - 1)
				local xg = (i - 1) - yg * MapRenderer.map.w

				love.graphics.draw(
					loadedTiles.tilesetImages[currTileset],
					loadedTiles.quads[currTileset][currTilePosId],
					xg * MapRenderer.map.gridW,
					yg * MapRenderer.map.gridH
				)
			end
		end
	end
	love.graphics.setCanvas()
	love.graphics.setColor(1, 1, 1)
end

function MapRenderer.draw()
	if MapRenderer.applyShader then
		love.graphics.setShader(MapRenderer.applyShader)
	end

	MapRenderer.cam:attach()
	love.graphics.draw(mapCanvas, 0, 0)
	love.graphics.setShader()
	MapRenderer.cam:detach()
end

function MapRenderer.disable() end

function MapRenderer.unload()
	mapCanvas = nil
	loadedTiles = nil
	MapRenderer.map = nil
end

return MapRenderer
