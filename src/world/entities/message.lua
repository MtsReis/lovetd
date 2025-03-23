local c = require("world.components")
local Entity = require("world.entities.entity")

local Message = class("Message", Entity)

function Message:initialize(text, canvas, options)
    Entity.initialize(self, options)
    local lifespan = options and options.lifespan or 2

    self.canvas = canvas

    self.message = c.message(text)
    self.lifespan = lifespan
end

return Message
