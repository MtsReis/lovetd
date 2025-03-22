--[[
i: Invoker
a: Agent
t: Target
]]
local effects_once = require("world.components")._effects_agent_on_target_once
local effects_constant = require("world.components")._effects_agent_on_target_constant
local EFFECT = require("world.components").EFFECT_ENUM

--[[
source: source entity ref
target: target entity ref
type: i
]]
local function applyEffects(source, target, sourceIdPrefix)
	local sourceId = sourceIdPrefix .. source.label or "" -- agent3_source1_source1

	-- Effect applied only once per target
	if not target.hurtbox.wasAffectedBy[sourceId] then
		for _, eff in ipairs(effects_once) do
			if source[eff] then
				if eff == "attack" and target.hp and type(target.hp.curr) then
					local inflictedDmg = math.random(
						source.attack.baseDamage - source.attack.minDamageDecrement,
						source.attack.baseDamage + source.attack.maxDamageIncrement
					)

					log.debug(
						"'%(s)s' inflicted a damage of '%(d)s' on '%(t)s'"
							% { s = source.label, d = inflictedDmg, t = target.label }
					)
					target.hp.curr = target.hp.curr - inflictedDmg
				end
			end
		end

		target.hurtbox.wasAffectedBy[sourceId] = true
	end
end
local handlers = {
	onHit = function(i, a, t) -- Apply both the Invoker's and the Agent's effects onto Target
		--log.debug("[event] %(i)s hit %(t)s through %(a)s" % { i = i and i.label or "nil", a = a.label, t = t.label })

		-- agent3_source1
		local sourceIdPrefix = "%(a)s%(i)s"
			% { a = a.label and a.label .. "_" or "", i = i.label and i.label .. "_" or "" }
		applyEffects(a, t, sourceIdPrefix)

		-- If source has no pierce, despawn
		-- if not a[EFFECT.pierce] or a[EFFECT.pierce] < 1 then
		-- 	a.lifespan = 0
		-- else
		-- 	a[EFFECT.pierce] = a[EFFECT.pierce] - 1
		-- end

		if i and i.label then
			applyEffects(i, t, sourceIdPrefix)
		end
	end,
}

return handlers
