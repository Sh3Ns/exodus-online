local OPCODE_GOD_MINIMAP_TELEPORT = 215

local function canUseGodMinimapTeleport(player)
	return player:getGroup():getAccess() and player:getAccountType() >= ACCOUNT_TYPE_GOD
end

local loginEvent = CreatureEvent("GodMinimapTeleportLogin")

function loginEvent.onLogin(player)
	player:registerEvent("GodMinimapTeleportOpcode")
	player:sendExtendedOpcode(OPCODE_GOD_MINIMAP_TELEPORT, json.encode({
		action = "access",
		enabled = canUseGodMinimapTeleport(player)
	}))
	return true
end

loginEvent:type("login")
loginEvent:register()

local opcodeEvent = CreatureEvent("GodMinimapTeleportOpcode")

function opcodeEvent.onExtendedOpcode(player, opcode, buffer)
	if opcode ~= OPCODE_GOD_MINIMAP_TELEPORT then
		return
	end

	if not canUseGodMinimapTeleport(player) then
		return
	end

	local data = json.decode(buffer)
	if type(data) ~= "table" or data.action ~= "teleport" or type(data.position) ~= "table" then
		return
	end

	local x = tonumber(data.position.x)
	local y = tonumber(data.position.y)
	local z = tonumber(data.position.z)
	if not x or not y or not z then
		return
	end

	x = math.floor(x)
	y = math.floor(y)
	z = math.floor(z)
	if x < 1 or x > 65535 or y < 1 or y > 65535 or z < 0 or z > 15 then
		return
	end

	local fromPosition = player:getPosition()
	local toPosition = Position(x, y, z)
	fromPosition:sendMagicEffect(CONST_ME_TELEPORT)
	player:teleportTo(toPosition)
	player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
end

opcodeEvent:type("extendedopcode")
opcodeEvent:register()
