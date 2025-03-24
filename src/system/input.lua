-- Translate Löve inputs into valid engine commands
local lovelyMoon = require 'lib.lovelyMoon'

local InputVerify = class('InputVerify')

InputVerify.commandList = {
	["MOUSE_1"] = "mouse_command",
	["MOUSE_2"] = "drag_screen",

	["f1"] = "toggle_hp",
	["f11"] = "toggle_fullscreen",
	["f12"] = "toggle_debug",
	["pause"] = "pause_game",

	["escape"] = "pause_game"
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
