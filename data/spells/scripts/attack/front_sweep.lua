local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_HITAREA)
combat:setParameter(COMBAT_PARAM_BLOCKARMOR, true)
combat:setParameter(COMBAT_PARAM_USECHARGES, true)
combat:setArea(createCombatArea(AREA_WAVE6, AREADIAGONAL_WAVE6))

function onGetFormulaValues(player, skill, attack, factor)
	local min = (player:getLevel() / 5) + (skill * attack * 0.04) + 11
	local max = (player:getLevel() / 5) + (skill * attack * 0.08) + 21
	local legs = player:getSlotItem(CONST_SLOT_ARMOR)
    if legs and legs:getId() == 30017 then
        min = math.floor(min * 1.04)
        max = math.floor(max * 1.04)
    end
	return -min, -max
end

combat:setCallback(CALLBACK_PARAM_SKILLVALUE, "onGetFormulaValues")

function onCastSpell(creature, variant)
	playSound(creature, "berserk.ogg")
	return combat:execute(creature, variant)
end
