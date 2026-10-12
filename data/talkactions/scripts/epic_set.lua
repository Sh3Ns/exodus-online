-- /epicset [set] [rareza 1-15] [tier 0-10]
-- Entrega un set completo de una sola vez.

local sets = {
	twilight = { 30601, 30602, 30603, 30604, 30608, 30607, 27833 },
	dawnforged = { 29878, 29879, 29880, 29881, 29882, 29884, 29889, 29890, 29916, 29919, 27833 },
	seraphic = { 29869, 29870, 29871, 29872, 29873, 29875, 29876, 29877, 29915, 29918, 27833 },
	myst = { 29861, 29862, 29863, 29864, 29865, 30938, 29867, 29868, 29914, 29917, 27833 },
	varruth = { 27019, 27022, 27025, 27028, 30607, 30608, 27833 },
	seetheras = { 27031, 27034, 27037, 27040, 30607, 30608, 27833 },
	felsinger = { 27043, 27046, 27049, 27052, 30607, 30608, 27833 },
	netherwave = { 27007, 27010, 27013, 27016, 30938, 30614, 27833 },
	deathlord = { 29560, 29561, 29562, 29563, 29559, 29558, 27833 },
}

local setNames = {}
for name in pairs(sets) do
	setNames[#setNames + 1] = name
end
table.sort(setNames)

local usage = "Usage: /epicset <set> [rareza 1-15] [tier 0-10]   Sets: " .. table.concat(setNames, ", ")

function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		player:sendCancelMessage("You need a god account to use this command.")
		return false
	end

	local split = splitTalkParam(param, "word n n")
	local setName = split[1] and split[1]:lower() or nil
	local rarity = tonumber(split[2])
	local tier = tonumber(split[3])

	if not setName then
		setName = "twilight"
	end

	local list = sets[setName]
	if not list then
		player:sendCancelMessage("Unknown set '" .. setName .. "'. " .. usage)
		return false
	end

	if rarity and (rarity < 1 or rarity > 15) then
		player:sendCancelMessage("Rarity must be between 1 and 15.")
		return false
	end

	if tier and (tier < 0 or tier > 10) then
		player:sendCancelMessage("Tier must be between 0 and 10.")
		return false
	end

	local given, failed, givenNames = 0, 0, {}

	for _, id in ipairs(list) do
		local item = nil
		if rarity then
			item = Game.createItemWithRarity(id, 1, rarity)
		end
		if not item then
			item = Game.createItem(id, 1)
		end

		if not item then
			failed = failed + 1
		else
			if tier then
				item:setCustomAttribute("forge_tier", tier)
			end

			if player:addItemEx(item) ~= RETURNVALUE_NOERROR then
				item:remove()
				failed = failed + 1
			else
				given = given + 1
				givenNames[#givenNames + 1] = ItemType(id):getName()
			end
		end
	end

	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)

	if given > 0 then
		player:sendTextMessage(MESSAGE_INFO_DESCR, string.format(
			"Set '%s' delivered: %d/%d items. Rarity: %s  Tier: %s",
			setName, given, #list, tostring(rarity or "-"), tostring(tier or "-")))
		player:sendTextMessage(MESSAGE_INFO_DESCR, table.concat(givenNames, ", "))
	end

	if failed > 0 then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, string.format(
			"Could not deliver %d item(s) - is your backpack full?", failed))
	end

	return false
end
