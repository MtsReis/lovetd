stds.amora = {
	globals = { "amora", "_L" },
	read_globals = { "pl", "pw", "pd", "class", "state" },
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
