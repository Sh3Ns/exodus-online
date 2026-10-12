local combat = Combat()
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, false)

local condition = Condition(CONDITION_MANASHIELD)
condition:setParameter(CONDITION_PARAM_TICKS, 200000)
combat:addCondition(condition)

function onCastSpell(creature, variant)
	playSound(creature, "utamo.ogg")
	local result = combat:execute(creature, variant)
	local player = Player(creature)
	if result and player and type(_G.GemsSocket_tryTriggerBoonstone) == "function" then
		_G.GemsSocket_tryTriggerBoonstone(player)
	end
	return result
end
