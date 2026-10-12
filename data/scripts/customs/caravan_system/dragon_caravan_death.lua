local STORAGE_DRAGON_CARAVAN_QUEST = 222280
local STORAGE_DRAGON_CARAVAN_BOSS_KILL = 222281

local config = {
	bossName = "Vorondor The Eternal Flames",
	creditRange = 15,
}

local function getChebyshevDistance(first, second)
	if first.z ~= second.z then
		return 999
	end

	return math.max(math.abs(first.x - second.x), math.abs(first.y - second.y))
end

local function getPlayerFromCreatureId(creatureId)
	local creature = Creature(creatureId)
	if not creature then
		return nil
	end

	local player = creature:getPlayer()
	if player then
		return player
	end

	local master = creature:getMaster()
	if master then
		return master:getPlayer()
	end

	return nil
end

local function giveDragonCaravanCredit(player, bossPosition, creditedPlayers)
	if not player then
		return
	end

	local playerId = player:getId()
	if creditedPlayers[playerId] then
		return
	end

	if getChebyshevDistance(player:getPosition(), bossPosition) > config.creditRange then
		return
	end

	if player:getStorageValue(STORAGE_DRAGON_CARAVAN_QUEST) ~= 2 then
		return
	end

	creditedPlayers[playerId] = true
	player:setStorageValue(STORAGE_DRAGON_CARAVAN_BOSS_KILL, 1)
	player:sendTextMessage(MESSAGE_INFO_DESCR, "You have defeated Vorondor The Eternal Flames. Return to Marek in Thais.")
end

local function giveCreditToPlayerAndParty(player, bossPosition, creditedPlayers)
	if not player then
		return
	end

	giveDragonCaravanCredit(player, bossPosition, creditedPlayers)

	local party = player:getParty()
	if not party then
		return
	end

	local leader = party:getLeader()
	if leader then
		giveDragonCaravanCredit(leader, bossPosition, creditedPlayers)
	end

	local members = party:getMembers()
	for i = 1, #members do
		giveDragonCaravanCredit(members[i], bossPosition, creditedPlayers)
	end
end

local vorondorDragonCaravanDeath = CreatureEvent("VorondorDragonCaravanDeath")

function vorondorDragonCaravanDeath.onDeath(creature, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
	if creature:getName() ~= config.bossName then
		return true
	end

	local bossPosition = creature:getPosition()
	local creditedPlayers = {}

	local damageMap = creature:getDamageMap()
	for creatureId, _ in pairs(damageMap) do
		local player = getPlayerFromCreatureId(creatureId)
		if player then
			giveCreditToPlayerAndParty(player, bossPosition, creditedPlayers)
		end
	end

	return true
end

vorondorDragonCaravanDeath:type("death")
vorondorDragonCaravanDeath:register()