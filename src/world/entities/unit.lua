local c = require("world.components")

local Unit = class("Unit")

function Unit:initialize(x, y, space, type, canvas)
	local W, H = 20, 20
	self.canvas = canvas

	self.pos = c.pos(x, y)
	self.geometry = c.geometry("rect", W, H, "fill", { 1, 0, 0, 1 } )
	self.dPivot = c.dPivot(W / 2, H / 2)

	self.velocity = c.velocity(0, 500)
	self.collisionbox = c.collisionbox(space, x, y, W, H, 0, 0)

	if type == "orc" then
		self.geometry.type = "circ"
		self.geometry.colour = {50/255, 148/255, 44/255, 1}
		self.dPivot = c.dPivot()
		self.velocity.speed = 50
		self.collisionbox = c.collisionbox(space, x, y, W, H, -W/2, -H/2)
	elseif type == "human" then
		self.geometry.colour = {10/255, 10/255, 10/255, 1}
		self.velocity.speed = 90
	end
		
end

return Unit
