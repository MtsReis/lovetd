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
    proto2 = { tileH = 32, tileW = 32 }
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

    -------------------------------------

    { "PATH_TL", 1, "proto2" }, -- 23
    { "PATH_T", 2, "proto2" }, -- 24
    { "PATH_TR", 3, "proto2" }, -- 25
    { "LAKE_TL", 4, "proto2" }, -- 26
    { "LAKE_T", 5, "proto2" }, -- 27
    { "LAKE_TR", 6, "proto2" }, -- 28
    { "PATH_L", 12, "proto2" }, -- 29
    { "PATH", 13, "proto2" }, -- 30
    { "PATH_R", 14, "proto2" }, -- 31
    { "LAKE_L", 15, "proto2" }, -- 32
    { "LAKE", 16, "proto2" }, -- 33
    { "LAKE_R", 17, "proto2" }, -- 34
    { "PLANT", 19, "proto2" }, -- 35
    { "PATH_BL", 23, "proto2" }, -- 36
    { "PATH_B", 24, "proto2" }, -- 37
    { "PATH_BR", 25, "proto2" }, -- 38
    { "LAKE_BL", 26, "proto2" }, -- 39
    { "LAKE_B", 27, "proto2" }, -- 40
    { "LAKE_BR", 28, "proto2" }, -- 41
    { "ROCK", 29, "proto2" }, -- 42
    { "DIRT_TL", 34, "proto2" }, -- 43
    { "DIRT_TR", 35, "proto2" }, -- 44
    { "GRASS_TL", 36, "proto2" }, -- 45
    { "GRASS_T", 37, "proto2" }, -- 46
    { "GRASS_TR", 38, "proto2" }, -- 47
    { "DIRT_BL", 45, "proto2" }, -- 48
    { "DIRT_BR", 46, "proto2" }, -- 49
    { "GRASS_L", 47, "proto2" }, -- 50
    { "GRASS", 48, "proto2" }, -- 51
    { "GRASS_R", 49, "proto2" }, -- 52
    { "LAKEOUT_TL", 51, "proto2" }, -- 53
    { "LAKEOUT_TR", 52, "proto2" }, -- 54
    { "DIRTOUT_TR", 53, "proto2" }, -- 55
    { "DIRTOUT_TR", 54, "proto2" }, -- 56
    { "GRASS_BL", 58, "proto2" }, -- 57
    { "GRASS_B", 59, "proto2" }, -- 58
    { "GRASS_BR", 60, "proto2" }, -- 59
    { "LIGHT_GRASS", 61, "proto2" }, -- 60
    { "LAKEOUT_BL", 62, "proto2" }, -- 61
    { "LAKEOUT_BR", 63, "proto2" }, -- 62
    { "DIRTOUT_TR", 64, "proto2" }, -- 63
    { "DIRTOUT_TR", 65, "proto2" }, -- 64
}

return { tile_source, game_tile }
