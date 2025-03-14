-- Translate Löve inputs into valid engine commands
local lovelyMoon = require 'lib.lovelyMoon'

local InputVerify = class('InputVerify')

InputVerify.commandList = {
	keyboard = {
		["a"] = "console"
	}
}

InputVerify.holdingKeys = {}

function InputVerify:keypressed(key)
	if self.commandList.keyboard[key] ~= nil then
		self.holdingKeys[key] = self.commandList.keyboard[key]
		lovelyMoon.keypressed(self.commandList.keyboard[key])
	end
end

function InputVerify:keyreleased(key)
	if self.commandList.keyboard[key] ~= nil then
		self.holdingKeys[key] = nil
		lovelyMoon.keyreleased(self.commandList.keyboard[key])
	end
end

function InputVerify:update()
	for key, command in pairs(self.holdingKeys) do
		lovelyMoon.keyhold(command)
	end
end

return InputVerify
