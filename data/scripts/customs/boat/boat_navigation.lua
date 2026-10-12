local boatSystem = MoveEvent()
print(">> Boat/Navigation System Loaded")

local BOAT_CARAVAN_WAS_ENABLED = 709924
local BOAT_NAVIGATION_ACTIVE = 709925
local CARAVAN_ENABLED_STORAGE = 222227

local OUTFIT_STORAGE = {
	lookType = 709919,
	lookAddons = 709920,
	lookWings = 709921,
	lookAura = 709922,
	lookShader = 709923,
}

local SEA_TILE_IDS = {
	[27725] = true,
	[27728] = true,
	[27729] = true,
	[27730] = true,
	[27731] = true,
}

local BOAT_LOOK_TYPES = {
	[1110] = true,
	[1111] = true,
	[1112] = true,
	[1113] = true,
	[1114] = true,
	[1115] = true,
	[1116] = true,
}

local BOATS = {
	{ storage = Ships.ScarletRaven, lookType = 1110 },
	{ storage = Ships.TheAwakener, lookType = 1111 },
	{ storage = Ships.TheCounterspell, lookType = 1112 },
	{ storage = Ships.TheExplorer, lookType = 1113 },
	{ storage = Ships.Whisperwind, lookType = 1114 },
	{ storage = Ships.MenethilMarch, lookType = 1115 },
	{ storage = Ships.Shadowmeld, lookType = 1116 },
}

local function getBoatLookType(player)
	for _, boat in ipairs(BOATS) do
		if player:getStorageValue(boat.storage) >= 1 then
			return boat.lookType
		end
	end
	return nil
end

local function isSeaPosition(position)
	if not position then
		return false
	end

	local tile = Tile(position)
	local ground = tile and tile:getGround()
	return ground and SEA_TILE_IDS[ground:getId()] or false
end

local function hasStoredOutfit(player)
	return player:getStorageValue(OUTFIT_STORAGE.lookType) > 0
end

local function saveOutfit(player, outfit)
	player:setStorageValue(OUTFIT_STORAGE.lookType, outfit.lookType)
	player:setStorageValue(OUTFIT_STORAGE.lookAddons, outfit.lookAddons or 0)
	player:setStorageValue(OUTFIT_STORAGE.lookWings, outfit.lookWings or 0)
	player:setStorageValue(OUTFIT_STORAGE.lookAura, outfit.lookAura or 0)
	player:setStorageValue(OUTFIT_STORAGE.lookShader, outfit.lookShader or 0)
end

local function applyBoatOutfit(player, lookType)
	local outfit = player:getOutfit()
	if outfit.lookType == lookType
			and outfit.lookAddons == 0
			and outfit.lookWings == 0
			and outfit.lookAura == 0
			and outfit.lookShader == 0 then
		return
	end

	outfit.lookType = lookType
	outfit.lookAddons = 0
	outfit.lookWings = 0
	outfit.lookAura = 0
	outfit.lookShader = 0
	player:setOutfit(outfit)
end

local function restoreCaravan(player)
	if ChariotSystem and player:getStorageValue(BOAT_CARAVAN_WAS_ENABLED) == 1 then
		player:setStorageValue(CARAVAN_ENABLED_STORAGE, 1)
		player:setStorageValue(BOAT_CARAVAN_WAS_ENABLED, -1)

		addEvent(function(playerId)
			local eventPlayer = Player(playerId)
			if eventPlayer then
				ChariotSystem.sync(eventPlayer)
			end
		end, 100, player:getId())
	else
		player:setStorageValue(BOAT_CARAVAN_WAS_ENABLED, -1)
	end
end

BoatNavigation = BoatNavigation or {}

function BoatNavigation.isAtSea(player)
	return player and isSeaPosition(player:getPosition())
end

function BoatNavigation.begin(player)
	local boatLookType = getBoatLookType(player)
	if not boatLookType then
		return false
	end

	if player:getStorageValue(BOAT_NAVIGATION_ACTIVE) ~= 1 then
		local currentOutfit = player:getOutfit()
		local storedLookType = player:getStorageValue(OUTFIT_STORAGE.lookType)

		-- Keep a valid pre-fix (flag) saved outfit instead of replacing it with a boat outfit while navigating > tp
		if not (BOAT_LOOK_TYPES[currentOutfit.lookType]
			and storedLookType > 0
			and not BOAT_LOOK_TYPES[storedLookType]) then
			saveOutfit(player, currentOutfit)
		end

		player:setStorageValue(BOAT_NAVIGATION_ACTIVE, 1)

		if ChariotSystem then
			player:setStorageValue(
				BOAT_CARAVAN_WAS_ENABLED,
				player:getStorageValue(CARAVAN_ENABLED_STORAGE) == 1 and 1 or -1
			)
			ChariotSystem.setEnabled(player, false)
		end
	end

	applyBoatOutfit(player, boatLookType)
	return true
end

function BoatNavigation.restore(player, shouldRestoreCaravan)
	if not player then
		return false
	end

	local currentOutfit = player:getOutfit()
	local wasNavigating = player:getStorageValue(BOAT_NAVIGATION_ACTIVE) == 1
		or BOAT_LOOK_TYPES[currentOutfit.lookType]
	if not wasNavigating then
		return false
	end

	local storedLookType = player:getStorageValue(OUTFIT_STORAGE.lookType)
	if storedLookType > 0 then
		currentOutfit.lookType = storedLookType
		currentOutfit.lookAddons = math.max(0, player:getStorageValue(OUTFIT_STORAGE.lookAddons))
		currentOutfit.lookWings = math.max(0, player:getStorageValue(OUTFIT_STORAGE.lookWings))
		currentOutfit.lookAura = math.max(0, player:getStorageValue(OUTFIT_STORAGE.lookAura))
		currentOutfit.lookShader = math.max(0, player:getStorageValue(OUTFIT_STORAGE.lookShader))
		player:setOutfit(currentOutfit)
	end

	player:setStorageValue(BOAT_NAVIGATION_ACTIVE, -1)
	if shouldRestoreCaravan == false then
		player:setStorageValue(BOAT_CARAVAN_WAS_ENABLED, -1)
	else
		restoreCaravan(player)
	end
	return storedLookType > 0
end

function BoatNavigation.check(player)
	if not player then
		return
	end

	if BoatNavigation.isAtSea(player) then
		-- Also handles scripts which teleport a player directly onto a sea tile or vice versa
		if getBoatLookType(player) then
			BoatNavigation.begin(player)
		elseif player:getStorageValue(BOAT_NAVIGATION_ACTIVE) == 1 then
			BoatNavigation.restore(player)
		end
		return
	end

	local currentOutfit = player:getOutfit()
	local storedLookType = player:getStorageValue(OUTFIT_STORAGE.lookType)

	-- The second condition repairs players left in a boat outfit by the old script.
	if player:getStorageValue(BOAT_NAVIGATION_ACTIVE) == 1
		or (BOAT_LOOK_TYPES[currentOutfit.lookType]
			and hasStoredOutfit(player)
			and not BOAT_LOOK_TYPES[storedLookType]) then
		BoatNavigation.restore(player)
	end
end

function boatSystem.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	if BoatNavigation.begin(player) then
		return true
	end

	player:teleportTo(fromPosition, true)
	player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	player:say("You need a boat to ship on the sea.", TALKTYPE_MONSTER_SAY)
	return true
end

boatSystem:id(27725, 27728, 27729, 27730, 27731)
boatSystem:register()

local boatStepOut = MoveEvent()

function boatStepOut.onStepOut(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	-- Delay until the engine has completed the move. Sea-to-sea movement stays active.
	addEvent(function(playerId)
		local eventPlayer = Player(playerId)
		if eventPlayer then
			BoatNavigation.check(eventPlayer)
		end
	end, 1, player:getId())
	return true
end

boatStepOut:type("stepout")
boatStepOut:id(27725, 27728, 27729, 27730, 27731)
boatStepOut:register()

local boatLogin = CreatureEvent("BoatNavigationLogin")

function boatLogin.onLogin(player)
	player:registerEvent("BoatNavigationThink")
	player:registerEvent("BoatNavigationDeath")

	-- Other login events may restore the regular outfit, so check after they finish (onDeath) to restore previous outfit
	addEvent(function(playerId)
		local eventPlayer = Player(playerId)
		if eventPlayer then
			BoatNavigation.check(eventPlayer)
		end
	end, 100, player:getId())
	return true
end

boatLogin:type("login")
boatLogin:register()

local boatThink = CreatureEvent("BoatNavigationThink")

function boatThink.onThink(player)
	BoatNavigation.check(player)
	return true
end

boatThink:type("think")
boatThink:register()

local boatDeath = CreatureEvent("BoatNavigationDeath")

function boatDeath.onDeath(player)
	BoatNavigation.restore(player, false)
	return true
end

boatDeath:type("death")
boatDeath:register()

local boatLogout = CreatureEvent("BoatNavigationLogout")

function boatLogout.onLogout(player)
	BoatNavigation.restore(player, false)
	return true
end

boatLogout:type("logout")
boatLogout:register()
