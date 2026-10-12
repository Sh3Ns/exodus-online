local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_HITAREA)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_ETHEREALSPEAR)
combat:setParameter(COMBAT_PARAM_BLOCKARMOR, true)

function onGetFormulaValues(player, skill, attack, factor)
	local distanceSkill = player:getEffectiveSkillLevel(SKILL_DISTANCE)
	local min = (player:getLevel() / 5) + distanceSkill + 7
	local max = (player:getLevel() / 5) + (distanceSkill * 1.5) + 13
	local armor = player:getSlotItem(CONST_SLOT_ARMOR)
    if armor and armor:getId() == 30021 then
        min = math.floor(min * 1.04)
        max = math.floor(max * 1.04)
    end
	return -min, -max
end

combat:setCallback(CALLBACK_PARAM_SKILLVALUE, "onGetFormulaValues")

function onCastSpell(creature, variant)
	playSound(creature, "arrow_1.ogg")
	return combat:execute(creature, variant)
end
