local I_TILESET_NAME = 3

local mapCanvas = love.graphics.newCanvas()

local MapRenderer = class("MapRenderer")
local gameTileSets, gameTiles = unpack(require("scenarios.maps"))
local loadedTiles = {}
local map = { layers = {}, w = 0, gridW = 0, gridH = 0 }

function MapRenderer.load(layers, mapW, tileSize)
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

	map.layers = layers
	map.w = mapW
	map.gridW = tileSize[1]
	map.gridH = tileSize[2]

	--print("MAP INFO: "..pw(loadedTiles))

	loadedTiles.quads = tileQuads
	loadedTiles.tilesetImages = tilesetImages
end

function MapRenderer.enable() end

function MapRenderer.update()
	love.graphics.setCanvas(mapCanvas)
	for _, layer in ipairs(map.layers) do
		for i, tile in ipairs(layer) do
			if tile ~= 0 then
				local currTile = gameTiles[tile]
				local currTilePosId = currTile[2]
				local currTileset = currTile[3]

				local yg = (math.ceil(i / map.w) - 1)
				local xg = (i - 1) - yg * map.w

				love.graphics.draw(
					loadedTiles.tilesetImages[currTileset],
					loadedTiles.quads[currTileset][currTilePosId],
					xg * map.gridW,
					yg * map.gridH
				)
			end
		end
	end
	love.graphics.setCanvas()
	love.graphics.setColor(1, 1, 1)
end

function MapRenderer.draw()
	love.graphics.draw(mapCanvas, 0, 0)
end

function MapRenderer.disable() end

function MapRenderer.unload() end

return MapRenderer
