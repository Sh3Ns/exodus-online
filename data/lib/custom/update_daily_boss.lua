function updateBoostedBossInDatabase()
	local randomMonsterIndex = math.random(#boostedBossesList)
	local randomMonster = boostedBossesList[randomMonsterIndex]

	local monsterType = MonsterType(randomMonster)

	local looktype = 0
	local lookHead = 0
	local lookBody = 0
	local lookLegs = 0
	local lookFeet = 0
	local lookAddons = 0

	if monsterType then
		local outfit = monsterType:getOutfit()
		if outfit then
			looktype = outfit.lookType or 0
			lookHead = outfit.lookHead or 0
			lookBody = outfit.lookBody or 0
			lookLegs = outfit.lookLegs or 0
			lookFeet = outfit.lookFeet or 0
			lookAddons = outfit.lookAddons or 0
		end
	end

	local query = string.format(
		"INSERT INTO `boosted_boss` (`date`, `boostname`, `raceid`, `looktype`, `lookhead`, `lookbody`, `looklegs`, `lookfeet`, `lookaddons`) VALUES (NOW(), %s, %s, %d, %d, %d, %d, %d, %d)",
		db.escapeString(randomMonster),
		db.escapeString(randomMonster),
		looktype,
		lookHead,
		lookBody,
		lookLegs,
		lookFeet,
		lookAddons
	)

	db.query(query)
	setGlobalStorageValue(PlayerStorageKeys.boostedBoss, randomMonsterIndex)
	print("Today's Boosted Boss: " .. randomMonster .. " | Looktype: " .. looktype)
end