local c = require("world.components")
local Entity = require("world.entities.entity")
local EFFECT = c.EFFECT_ENUM

local Spawner = class("Spawner", Entity)

function Spawner:initialize(x, y, cooldown, amount, options, blueprint, ...)
    Entity.initialize(self, options)

    self.pos = c.pos(x, y)
    self.spawnOverTime = c.spawnOverTime(cooldown, amount, blueprint, ...)
end

return Spawner
