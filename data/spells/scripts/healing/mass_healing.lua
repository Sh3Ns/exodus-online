local combat = Combat()
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
combat:setParameter(COMBAT_PARAM_DISPEL, CONDITION_PARALYZE)
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, false)
combat:setArea(createCombatArea(AREA_CIRCLE3X3))

local mentorStorage = 405906

function onCastSpell(creature, variant)
	local min = (creature:getLevel() / 5) + (creature:getMagicLevel() * 4.6) + 100
	local max = (creature:getLevel() / 5) + (creature:getMagicLevel() * 9.6) + 125
	if creature:getStorageValue(mentorStorage) == 1 and creature:isDruid() then
		min = math.floor(min * 1.05)
		max = math.floor(max * 1.05)
	end
	for _, target in ipairs(combat:getTargets(creature, variant)) do
		local master = target:getMaster()
		if target:isPlayer() or master and master:isPlayer() then
			doTargetCombat(creature, target, COMBAT_HEALING, min, max)
		end
	end
	playSound(creature, "heal_4.ogg")
	return true
end
