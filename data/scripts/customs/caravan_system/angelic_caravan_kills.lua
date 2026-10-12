local STORAGE_ANGELIC_CARAVAN_QUEST = 222300
local STORAGE_ANGELIC_CARAVAN_CLEANSE_COUNT = 222302

local REQUIRED_KILLS = 1000

local cleanseMonsters = {
	["archon"] = true,
	["aeliana"] = true,
	["baalzebul"] = true,
	["lyrael"] = true,
	["nyxion"] = true,
	["oroniel"] = true,
	["sagittarius"] = true,
	["seraphiel"] = true
}

local angelicCleanseKill = CreatureEvent("AngelicCaravanCleanseKill")

function angelicCleanseKill.onDeath(creature, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
	local monsterName = creature:getName():lower()
	if not cleanseMonsters[monsterName] then
		return true
	end

	local player = killer and killer:getPlayer()
	if not player and killer then
		local master = killer:getMaster()
		player = master and master:getPlayer()
	end

	if not player then
		return true
	end

	if player:getStorageValue(STORAGE_ANGELIC_CARAVAN_QUEST) ~= 5 then
		return true
	end

	local count = math.max(player:getStorageValue(STORAGE_ANGELIC_CARAVAN_CLEANSE_COUNT), 0)
	if count >= REQUIRED_KILLS then
		return true
	end

	count = count + 1
	player:setStorageValue(STORAGE_ANGELIC_CARAVAN_CLEANSE_COUNT, count)

	if count >= REQUIRED_KILLS then
		player:setStorageValue(STORAGE_ANGELIC_CARAVAN_QUEST, 6)
		player:sendTextMessage(MESSAGE_INFO_DESCR, "You have cleansed enough corrupted servants. Return to Seraphina.")
	else
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Corrupted servants cleansed: " .. count .. " / " .. REQUIRED_KILLS .. ".")
	end

	return true
end

angelicCleanseKill:type("death")
angelicCleanseKill:register()