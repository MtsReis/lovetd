local c = require("world.components")

local Tower = class("Tower")

function Tower:initialize(x, y, space, type, canvas)
	local W, H = 40, 40
	self.canvas = canvas

	self.pos = c.pos(x, y)
	self.geometry = c.geometry("rect", W, H, "fill", { 1, 0, 1, 1 })
	self.dPivot = c.dPivot(W / 2, H / 2)

	self.range = c.range(space, x, y, 100, true)

	self.action = c.action("idle", {})
	-- temp
	self.attack = { mode = "aggressive" }
	self.ai = true
end

return Tower
