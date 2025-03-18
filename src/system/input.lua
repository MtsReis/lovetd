-- Translate Löve inputs into valid engine commands
local lovelyMoon = require 'lib.lovelyMoon'

local InputVerify = class('InputVerify')

InputVerify.commandList = {
	["a"] = "console",
	["MOUSE_3"] = "toggle_debug",
	["MOUSE_2"] = "drag_screen"
}

InputVerify.holdingKeys = {}

function InputVerify:keypressed(key)
	if self.commandList[key] ~= nil then
		self.holdingKeys[key] = self.commandList[key]
		lovelyMoon.keypressed(self.commandList[key])
	end
end

function InputVerify:keyreleased(key)
	if self.commandList[key] ~= nil then
		self.holdingKeys[key] = nil
		lovelyMoon.keyreleased(self.commandList[key])
	end
end

function InputVerify:update()
	for _, command in pairs(self.holdingKeys) do
		lovelyMoon.keyhold(command)
	end
end

return InputVerify
