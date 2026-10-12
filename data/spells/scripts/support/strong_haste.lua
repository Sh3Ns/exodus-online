local combat = Combat()
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_GREEN)
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, false)

local condition = Condition(CONDITION_HASTE)
condition:setParameter(CONDITION_PARAM_TICKS, 22000)
condition:setFormula(0.7, -56, 0.7, -56)
combat:addCondition(condition)

function onCastSpell(creature, variant)
	playSound(creature, "haste.ogg")
	local result = combat:execute(creature, variant)
	local player = Player(creature)
	if result and player and type(_G.GemsSocket_tryTriggerBoonstone) == "function" then
		_G.GemsSocket_tryTriggerBoonstone(player)
	end
	return result
end
