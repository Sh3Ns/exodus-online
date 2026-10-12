local STORAGE_ANGELIC_CARAVAN_QUEST = 222300
local STORAGE_ANGELIC_CARAVAN_BOSS_KILL = 222303

local config = {
	bossName = "Azazel the Infernal Seraph",
	creditRange = 15
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

local function giveAngelicBossCredit(player, bossPosition, creditedPlayers)
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

	if player:getStorageValue(STORAGE_ANGELIC_CARAVAN_QUEST) ~= 7 then
		return
	end

	creditedPlayers[playerId] = true
	player:setStorageValue(STORAGE_ANGELIC_CARAVAN_BOSS_KILL, 1)
	player:setStorageValue(STORAGE_ANGELIC_CARAVAN_QUEST, 8)
	player:sendTextMessage(MESSAGE_INFO_DESCR, "You have defeated Azazel the Infernal Seraph. Return to Marek in Thais.")
end

local function giveCreditToPlayerAndParty(player, bossPosition, creditedPlayers)
	giveAngelicBossCredit(player, bossPosition, creditedPlayers)

	local party = player:getParty()
	if not party then
		return
	end

	local leader = party:getLeader()
	if leader then
		giveAngelicBossCredit(leader, bossPosition, creditedPlayers)
	end

	local members = party:getMembers()
	for i = 1, #members do
		giveAngelicBossCredit(members[i], bossPosition, creditedPlayers)
	end
end

local azazelAngelicCaravanDeath = CreatureEvent("AzazelAngelicCaravanDeath")

function azazelAngelicCaravanDeath.onDeath(creature, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
	if creature:getName():lower() ~= config.bossName:lower() then
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

azazelAngelicCaravanDeath:type("death")
azazelAngelicCaravanDeath:register()