local combat = Combat()
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_GREEN)
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, false)

local speed = Condition(CONDITION_HASTE)
speed:setParameter(CONDITION_PARAM_TICKS, 10000)
speed:setFormula(0.8, -64, 0.8, -64)
combat:addCondition(speed)

local pacified = Condition(CONDITION_PACIFIED)
pacified:setParameter(CONDITION_PARAM_TICKS, 10000)
combat:addCondition(pacified)

function onCastSpell(creature, variant)
	playSound(creature, "haste.ogg")
	local result = combat:execute(creature, variant)
	local player = Player(creature)
	if result and player and type(_G.GemsSocket_tryTriggerBoonstone) == "function" then
		_G.GemsSocket_tryTriggerBoonstone(player)
	end
	return result
end
