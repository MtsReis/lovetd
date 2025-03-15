--[[
    <tileset_name> = { gridW = <width in pixels>, gridH = <height in pixels> }

    Where
    - tileset_name: the image file name without the file extension (.png).
    Only letters, numbers and underscores are allowed

    - gridW and gridH: The size in pixel for every separate tile in this tileset
]]
local tile_source = {
	geometric = { gridH = 32, gridW = 32 },
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
	{ "WHITE_SQUARE", 1, "geometric" }, -- 1
    { "RED_SQUARE", 2, "geometric" },
    { "GREEN_SQUARE", 3, "geometric" },
}

return { tile_source, game_tile }
