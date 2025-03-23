--[[
i: Invoker
a: Agent
t: Target
]]
local c = require("world.components")
local EFFECT = c.EFFECT_ENUM
local CONDITION = c.CONDITION_ENUM
local effects_once = require("world.components")._effects_agent_on_target_once
local effects_constant = require("world.components")._effects_agent_on_target_constant

--[[
source: source entity ref
target: target entity ref
type: i
]]
local function applyEffects(source, target, sourceIdPrefix, isAgent)
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
				elseif EFFECT.curse then
					-- Roll dice
					if math.random() <= source[EFFECT.curse] / 100 then
						target[CONDITION.cursed] = c[CONDITION.cursed](source.team)
					end
				end
			end
		end

		-- If source has no pierce, despawn
		if isAgent then
			if not source[EFFECT.pierce] or source[EFFECT.pierce] < 1 then
				source.lifespan = 0
			else
				source[EFFECT.pierce] = source[EFFECT.pierce] - 1
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
		applyEffects(a, t, sourceIdPrefix, true)

		if i and i.label then
			applyEffects(i, t, sourceIdPrefix, false)
		end
	end,
}

return handlers
