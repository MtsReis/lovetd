--[[
    <tileset_name> = { tileW = <width in pixels>, tileH = <height in pixels> }

    Where
    - tileset_name: the image file name without the file extension (.png).
    Only letters, numbers and underscores are allowed

    - tileW and tileH: The size in pixel for every separate tile in this tileset
]]
local tile_source = {
	geometric = { tileH = 20, tileW = 20 },
    proto = { tileH = 32, tileW = 32 },
    proto2 = { tileH = 32, tileW = 32 },
    bigsingletile = { tileH = 512, tileW = 512 },
}

--[[
    Order matters for this list!

    {"<tile_name>", <position>, "<tileset_name>"}

    Where
    - tile_name: just an identifier for this specific tile
    - position: what's its grid position in the tileset image
    - tileset_name: which of the tilesets above this tile is part of
]]
local game_tile = {
	{ "GRASS", 1, "proto2" }, -- 1
    { "GRASS_FLOWER", 2, "proto2" },
    { "BROKEN_TILE", 3, "proto2" },
    { "TILE_BIT", 4, "proto2" }
}

return { tile_source, game_tile }
