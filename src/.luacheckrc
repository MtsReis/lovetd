stds.amora = {
	globals = { "amora", "_L", "vec2", "pw", "pd" },
	read_globals = { "pl", "class", "state", "vec2" },
}

std = "luajit+lua52+love+amora"

include_files = {
	"main.lua",
	"conf.lua",
	"states/*",
	"system/*",
	"views/*",
	"lib/*",
}
exclude_files = {
	"lib/i18n/*",
	"lib/pl/*",
	"lib/lovebird.lua",
	"lib/middleclass.lua",
	"output/",
	"spec/",
}

allow_defined_top = true
