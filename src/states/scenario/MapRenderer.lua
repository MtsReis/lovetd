local I_TILESET_NAME = 3

local MapRenderer = class("MapRenderer")
local gameTileSets, gameTiles = unpack(require("scenarios.maps"))

function MapRenderer.load(map)
	local precache = { tiles = {}, tilesets = {} }
	local hash = { tiles = {}, tilesets = {} }

	for _, layer in ipairs(map) do
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
end

function MapRenderer.enable() end

function MapRenderer.update() end

function MapRenderer.disable() end

function MapRenderer.unload() end

return MapRenderer
