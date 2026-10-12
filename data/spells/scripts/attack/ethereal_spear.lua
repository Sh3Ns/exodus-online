local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_HITAREA)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_ETHEREALSPEAR)
combat:setParameter(COMBAT_PARAM_BLOCKARMOR, true)

function onGetFormulaValues(player, skill, attack, factor)
	local distanceSkill = player:getEffectiveSkillLevel(SKILL_DISTANCE)
	local min = (player:getLevel() / 5) + distanceSkill * 0.7
	local max = (player:getLevel() / 5) + distanceSkill + 5
	local head = player:getSlotItem(CONST_SLOT_HEAD)
	local legs = player:getSlotItem(CONST_SLOT_LEGS)
	if head and head:getId() == 30110 then
		min = min * 1.40
		max = max * 1.40
	end
	if legs and legs:getId() == 30115 then
		min = min * 1.40
		max = max * 1.40
	end
	return -min, -max
end

combat:setCallback(CALLBACK_PARAM_SKILLVALUE, "onGetFormulaValues")

function onCastSpell(creature, variant)
	playSound(creature, "arrow_1.ogg")
	return combat:execute(creature, variant)
end
