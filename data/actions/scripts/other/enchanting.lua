local config = {
	manaCost = 300,
	soulCost = 2,
}

local spheres = {
	[7759] = {3, 7},
	[7760] = {1, 5, 9, 10},
	[7761] = {2, 6},
}

local enchantableGems = {2147, 2146, 2149, 2150}
local enchantableItems = {2383, 7383, 7384, 7406, 7402, 2429, 2430, 7389, 7380, 2454, 2423, 2445, 7415, 7392, 2391, 2544, 8905}

local enchantingAltars = {
	{7504, 7505, 7506, 7507},
	{7508, 7509, 7510, 7511},
	{7516, 7517, 7518, 7519},
	{7512, 7513, 7514, 7515}
}

local enchantedGems = {7760, 7759, 7761}
local enchantedItems = {
	[2383] = {7744, 7763, 7854, 7869},
	[7383] = {7745, 7764, 7855, 7870},
	[7384] = {7746, 7765, 7856, 7871},
	[7406] = {7747, 7766, 7857, 7872},
	[7402] = {7748, 7767, 7858, 7873},
	[2429] = {7749, 7768, 7859, 7874},
	[2430] = {7750, 7769, 7860, 7875},
	[7389] = {7751, 7770, 7861, 7876},
	[7380] = {7752, 7771, 7862, 7877},
	[2454] = {7753, 7772, 7863, 7878},
	[2423] = {7754, 7773, 7864, 7879},
	[2445] = {7755, 7774, 7865, 7880},
	[7415] = {7756, 7775, 7866, 7881},
	[7392] = {7757, 7776, 7867, 7882},
	[2391] = {7758, 7777, 7868, 7883},
	[2544] = {7840, 7839, 7850, 7838},
	[8905] = {8906, 8907, 8909, 8908}
}

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if isInArray({33268, 33269}, toPosition.x) and toPosition.y == 31830 and toPosition.z == 10 and player:getStorageValue(Storage.ElementalSphere.QuestLine) > 0 then
		if not isInArray(spheres[item.itemid], player:getVocation():getId()) then
			player:say("Your vocation can't use this gem here.", TALKTYPE_MONSTER_SAY)
			return true
		end

		if target.itemid == 7911 then
			player:say("Machine is OFF.", TALKTYPE_MONSTER_SAY)
		elseif target.itemid == 7912 then
			player:say("Machine is ON. You must turn it OFF to use gems.", TALKTYPE_MONSTER_SAY)
			return true
		else
			player:say("This doesn't look like a valid machine.", TALKTYPE_MONSTER_SAY)
			return true
		end

		local currentCount = math.max(0, player:getStorageValue(Storage.ElementalSphere.MachineGemCount))
		if currentCount >= 20 then
			player:say("You already inserted 20 gems.", TALKTYPE_MONSTER_SAY)
			return true
		end

		player:setStorageValue(Storage.ElementalSphere.MachineGemCount, currentCount + 1)

		if item.type > 1 then
			item:transform(item.itemid, item.type - 1)
		else
			item:remove()
		end

		toPosition:sendMagicEffect(CONST_ME_PURPLEENERGY)

		if currentCount + 1 == 20 then
			player:say("You inserted the final gem. Machine fully charged!", TALKTYPE_MONSTER_YELL)
			toPosition:sendMagicEffect(CONST_ME_ENERGYHIT)
		end

		return true
	end


	if item.itemid == 2147 and target.itemid == 2342 then
		target:transform(2343)
		target:decay()
		item:remove(1)
		toPosition:sendMagicEffect(CONST_ME_MAGIC_RED)
		return true
	end

	if item.itemid == 7760 and isInArray({9934, 10022}, target.itemid) then
		target:transform(9933)
		item:remove(1)
		toPosition:sendMagicEffect(CONST_ME_MAGIC_RED)
		return true
	end

	if isInArray(enchantableGems, item.itemid) then
		local subtype = item.type
		if subtype == 0 then
			subtype = 1
		end

		local mana = config.manaCost * subtype
		if player:getMana() < mana then
			player:say('Not enough mana, separate one gem in your backpack and try again.', TALKTYPE_MONSTER_SAY)
			return false
		end

		local soul = config.soulCost * subtype
		if player:getSoul() < soul then
			player:sendCancelMessage(RETURNVALUE_NOTENOUGHSOUL)
			return false
		end

		local targetId = table.find(enchantableGems, item.itemid)
		if not targetId or not enchantingAltars[targetId] or not isInArray(enchantingAltars[targetId], target.itemid) then
			fromPosition:sendMagicEffect(CONST_ME_POFF)
			return false
		end

		player:addMana(-mana)
		player:addSoul(-soul)
		item:transform(enchantedGems[targetId])
		player:addManaSpent(mana * configManager.getNumber(configKeys.RATE_MAGIC))
		player:getPosition():sendMagicEffect(CONST_ME_HOLYDAMAGE)
		return true
	end

	if item.itemid == 7761 and isInArray({9949, 9954}, target.itemid) then
		target:transform(target.itemid - 1)
		target:decay()
		item:remove(1)
		toPosition:sendMagicEffect(CONST_ME_MAGIC_GREEN)
		return true
	end

	if isInArray(enchantedGems, item.itemid) then
		if not isInArray(enchantableItems, target.itemid) then
			fromPosition:sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local targetId = table.find(enchantedGems, item.itemid)
		if not targetId then
			return false
		end

		local subtype = target.type
		if not isInArray({2544, 8905}, target.itemid) then
			subtype = 1000
		end

		target:transform(enchantedItems[target.itemid][targetId], subtype)
		target:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
		item:remove(1)
		return true
	end
	return false
end
