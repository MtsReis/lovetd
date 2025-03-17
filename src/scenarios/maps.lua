--[[
    <tileset_name> = { tileW = <width in pixels>, tileH = <height in pixels> }

    Where
    - tileset_name: the image file name without the file extension (.png).
    Only letters, numbers and underscores are allowed

    - tileW and tileH: The size in pixel for every separate tile in this tileset
]]
local tile_source = {
	geometric = { tileH = 20, tileW = 20 },
    proto = { tileH = 32, tileW = 32 }
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
    { "GRASS_TL", 1, "proto" }, -- 1
    { "GRASS_T", 2, "proto" },
    { "GRASS_TR", 3, "proto" },

    { "PATH_TL", 4, "proto" }, -- 4
    { "PATH_T", 5, "proto" },
    { "PATH_TR", 6, "proto" },

    { "ROCK", 7, "proto" }, -- 7

    { "GRASS_L", 8, "proto" }, -- 8
    { "GRASS", 9, "proto" },
    { "GRASS_R", 10, "proto" },

    { "PATH_L", 11, "proto" }, -- 11
    { "PATH", 12, "proto" },
    { "PATH_R", 13, "proto" },

    { "BLANK", 14, "proto" }, -- 14

    { "GRASS_BL", 15, "proto" }, -- 15
    { "GRASS_B", 16, "proto" },
    { "GRASS_BR", 17, "proto" },

    { "PATH_BL", 18, "proto" }, -- 18
    { "PATH_B", 19, "proto" },
    { "PATH_BR", 20, "proto" },

	{ "LIGHT_GRASS", 21, "proto" }, -- 21

    -------------------------------------

    { "BLUE_SQUARE", 3, "geometric" }, -- 22
}

return { tile_source, game_tile }
