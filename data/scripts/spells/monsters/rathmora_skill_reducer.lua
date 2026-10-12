local combat = Combat()
combat:setParameter(COMBAT_PARAM_EFFECT, 352)

local condition = Condition(CONDITION_ATTRIBUTES)
condition:setParameter(CONDITION_PARAM_TICKS, 6000)
condition:setParameter(CONDITION_PARAM_SKILL_DISTANCE, -15)
condition:setParameter(CONDITION_PARAM_SKILL_SHIELD, -15)
condition:setParameter(CONDITION_PARAM_SKILL_MELEE, -15)
condition:setParameter(CONDITION_PARAM_STAT_MAGICPOINTS, -15)
local area = createCombatArea(AREA_CIRCLE6X6)

combat:setArea(area)
combat:addCondition(condition)

local spell = Spell("instant")

function spell.onCastSpell(creature, var)
	return combat:execute(creature, var)
end

spell:name("rathmora skill reducer")
spell:words("###1137")
spell:isAggressive(true)
spell:blockWalls(true)
spell:needLearn(true)
spell:register()