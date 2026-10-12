local combat = Combat()
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_STUN)
combat:setArea(createCombatArea(AREA_CIRCLE6X6))

local parameters = {
    {key = CONDITION_PARAM_TICKS, value = 4 * 1000},
    {key = CONDITION_PARAM_SKILL_AXEPERCENT, value = 25},
    {key = CONDITION_PARAM_SKILL_SWORDPERCENT, value = 25},
    {key = CONDITION_PARAM_SKILL_CLUBPERCENT, value = 25},
	{key = CONDITION_PARAM_SKILL_FISTPERCENT, value = 25},
    {key = CONDITION_PARAM_SKILL_DISTANCEPERCENT, value = 25},
    {key = CONDITION_PARAM_SKILL_SHIELDPERCENT, value = 25},
    {key = CONDITION_PARAM_STAT_MAGICPOINTSPERCENT, value = 25}
}


function onCastSpell(creature, variant)
	for _, target in ipairs(combat:getTargets(creature, variant)) do
		target:addAttributeCondition(parameters)
	end
	return true
end
