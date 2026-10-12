MonkHarmony = MonkHarmony or {}

local Harmony = MonkHarmony

Harmony.OPCODE = 237
Harmony.MAX_POINTS = 5
Harmony.POINTS_STORAGE = 405907
Harmony.VIRTUE_HARMONY_STORAGE = 405903
Harmony.VIRTUE_SUSTAIN_STORAGE = 405902
Harmony.SERENE_STORAGE = 405905
Harmony.SERENE_DURATION_MS = 7000
Harmony.BUILDER_COOLDOWN_REDUCTION_MS = 2000
Harmony.PARTY_HEAL_RANGE = 7

Harmony.BUILDER_SPELL_IDS = {398, 399, 407, 409, 412, 414}
Harmony.SPENDER_SPELL_IDS = {401, 402, 410}

-- 1 = 7%, 2 = 14%, 3 = 28%, 4 = 56%, 5 = 112%.
Harmony.SPENDER_BASE_BONUS = 0.07
Harmony.VIRTUE_BASE_BONUS = 0.03
Harmony.SERENE_VIRTUE_BASE_BONUS = 0.06
Harmony.HEAL_LEVEL_FACTOR = 0.25
Harmony.HEAL_MAGIC_FACTOR = 4.0
Harmony.HEAL_BASE = 25

local spendContexts = {}
local sereneTimers = {}

local function clamp(value, minimum, maximum)
	return math.max(minimum, math.min(maximum, value))
end

function Harmony.isMonk(player)
	if not player or not player:isPlayer() then
		return false
	end
	local vocation = player:getVocation()
	local vocationId = vocation and vocation:getId() or 0
	return vocationId == 11 or vocationId == 12
end

function Harmony.getPoints(player)
	if not Harmony.isMonk(player) then
		return 0
	end
	return clamp(player:getStorageValue(Harmony.POINTS_STORAGE), 0, Harmony.MAX_POINTS)
end

function Harmony.send(player)
	if not player or not player:isPlayer() then
		return false
	end
	return player:sendExtendedOpcode(Harmony.OPCODE, json.encode({
		points = Harmony.getPoints(player),
		max = Harmony.MAX_POINTS,
		visible = Harmony.isMonk(player)
	}))
end

function Harmony.setPoints(player, points, skipHealing)
	if not Harmony.isMonk(player) then
		if player and player:isPlayer() then
			player:setStorageValue(Harmony.POINTS_STORAGE, 0)
			Harmony.send(player)
		end
		return 0
	end

	local oldPoints = Harmony.getPoints(player)
	local newPoints = clamp(math.floor(tonumber(points) or 0), 0, Harmony.MAX_POINTS)
	player:setStorageValue(Harmony.POINTS_STORAGE, newPoints)
	Harmony.send(player)

	if not skipHealing and newPoints > oldPoints then
		Harmony.triggerVirtueHealing(player, newPoints - oldPoints)
	end
	return newPoints
end

local function addCandidate(candidates, seen, player, origin)
	if not player or not player:isPlayer() or player:getHealth() <= 0 then
		return
	end
	local position = player:getPosition()
	if not position or position.z ~= origin.z or position:getDistance(origin) > Harmony.PARTY_HEAL_RANGE then
		return
	end
	local id = player:getId()
	if seen[id] then
		return
	end
	seen[id] = true
	candidates[#candidates + 1] = player
end

function Harmony.getVirtueHealingTarget(player)
	local origin = player:getPosition()
	local candidates = {}
	local seen = {}
	local party = player:getParty()

	if party then
		addCandidate(candidates, seen, party:getLeader(), origin)
		for _, member in ipairs(party:getMembers()) do
			addCandidate(candidates, seen, member, origin)
		end
	else
		addCandidate(candidates, seen, player, origin)
	end

	local bestTarget
	local lowestPercent = math.huge
	for _, candidate in ipairs(candidates) do
		local maxHealth = math.max(1, candidate:getMaxHealth())
		local healthPercent = candidate:getHealth() / maxHealth
		if healthPercent < lowestPercent then
			lowestPercent = healthPercent
			bestTarget = candidate
		end
	end
	return bestTarget or player
end

function Harmony.triggerVirtueHealing(player, harmonyAmount)
	if not Harmony.isMonk(player) then
		return false
	end
	local target = Harmony.getVirtueHealingTarget(player)
	if not target then
		return false
	end
	harmonyAmount = math.max(1, math.floor(tonumber(harmonyAmount) or 1))
	local amount = math.max(1, math.floor((
		(player:getLevel() * Harmony.HEAL_LEVEL_FACTOR) +
		(player:getMagicLevel() * Harmony.HEAL_MAGIC_FACTOR) +
		Harmony.HEAL_BASE
	) * harmonyAmount))
	if player:getStorageValue(Harmony.VIRTUE_SUSTAIN_STORAGE) == 1 then
		amount = math.floor(amount * (Harmony.isSerene(player) and 1.70 or 1.35))
	end
	target:addHealth("healing", amount)
	target:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
	return true
end

function Harmony.add(player, amount)
	if not Harmony.isMonk(player) then
		return 0
	end
	amount = math.max(0, math.floor(tonumber(amount) or 1))
	if amount == 0 then
		return Harmony.getPoints(player)
	end
	return Harmony.setPoints(player, Harmony.getPoints(player) + amount)
end

function Harmony.isSerene(player)
	return Harmony.isMonk(player) and player:getStorageValue(Harmony.SERENE_STORAGE) == 1
end

function Harmony.getSpendMultiplier(player, points)
	points = clamp(math.floor(tonumber(points) or 0), 0, Harmony.MAX_POINTS)
	if points <= 0 then
		return 1
	end

	local baseBonus = Harmony.SPENDER_BASE_BONUS
	if player:getStorageValue(Harmony.VIRTUE_HARMONY_STORAGE) == 1 then
		baseBonus = baseBonus + (Harmony.isSerene(player)
			and Harmony.SERENE_VIRTUE_BASE_BONUS
			or Harmony.VIRTUE_BASE_BONUS)
	end
	return 1 + (baseBonus * (2 ^ (points - 1)))
end

function Harmony.beginSpend(player)
	if not Harmony.isMonk(player) then
		return {points = 0, multiplier = 1}
	end
	local points = Harmony.getPoints(player)
	local context = {
		points = points,
		multiplier = Harmony.getSpendMultiplier(player, points)
	}
	spendContexts[player:getId()] = context
	return context
end

function Harmony.scaleDamage(player, minimum, maximum)
	local context = player and spendContexts[player:getId()]
	local multiplier = context and context.multiplier or 1
	return math.floor(minimum * multiplier), math.floor(maximum * multiplier)
end

function Harmony.reduceBuilderCooldowns(player, points)
	if not player or points <= 0 then
		return
	end
	local reduction = points * Harmony.BUILDER_COOLDOWN_REDUCTION_MS
	for _, spellId in ipairs(Harmony.BUILDER_SPELL_IDS) do
		if type(player.reduceSpellCooldown) == "function" then
			player:reduceSpellCooldown(spellId, reduction)
		end
	end
end

function Harmony.finishSpend(player, context, success)
	if not player or not player:isPlayer() then
		return false
	end
	spendContexts[player:getId()] = nil
	if not success or not context or context.points <= 0 then
		return success == true
	end

	Harmony.reduceBuilderCooldowns(player, context.points)
	Harmony.setPoints(player, 0, true)
	Harmony.triggerVirtueHealing(player, context.points)

	if player:getStorageValue(Harmony.VIRTUE_HARMONY_STORAGE) == 1 then
		Harmony.setPoints(player, 1, true)
	end
	return true
end

function Harmony.castBuilder(player, combat, variant, amount)
	local success = combat:execute(player, variant)
	if success then
		Harmony.add(player, amount or 1)
	end
	return success
end

function Harmony.castSpender(player, combat, variant)
	local context = Harmony.beginSpend(player)
	local success = combat:execute(player, variant)
	Harmony.finishSpend(player, context, success)
	return success
end

local function endSerene(playerId)
	sereneTimers[playerId] = nil
	local player = Player(playerId)
	if not player then
		return
	end
	player:setStorageValue(Harmony.SERENE_STORAGE, -1)
	Harmony.send(player)
end

function Harmony.activateSerenity(player)
	if not Harmony.isMonk(player) then
		return false
	end
	local playerId = player:getId()
	if sereneTimers[playerId] then
		stopEvent(sereneTimers[playerId])
	end
	player:setStorageValue(Harmony.SERENE_STORAGE, 1)
	Harmony.setPoints(player, Harmony.MAX_POINTS, true)

	for _, spellId in ipairs(Harmony.SPENDER_SPELL_IDS) do
		if type(player.reduceSpellCooldown) == "function" then
			player:reduceSpellCooldown(spellId, 2147483647)
		else
			player:removeCondition(CONDITION_SPELLCOOLDOWN, CONDITIONID_DEFAULT, spellId, true)
		end
	end
	sereneTimers[playerId] = addEvent(endSerene, Harmony.SERENE_DURATION_MS, playerId)
	return true
end

local loginEvent = CreatureEvent("MonkHarmonyLogin")
function loginEvent.onLogin(player)
	player:registerEvent("MonkHarmonyDeath")
	player:registerEvent("MonkHarmonyLogout")
	player:registerEvent("MonkHarmonyExtended")
	player:setStorageValue(Harmony.POINTS_STORAGE, 0)
	player:setStorageValue(Harmony.SERENE_STORAGE, -1)
	addEvent(function(playerId)
		local eventPlayer = Player(playerId)
		if eventPlayer then
			Harmony.send(eventPlayer)
		end
	end, 750, player:getId())
	return true
end
loginEvent:register()

local extendedEvent = CreatureEvent("MonkHarmonyExtended")
function extendedEvent.onExtendedOpcode(player, opcode)
	if opcode ~= Harmony.OPCODE then
		return true
	end
	Harmony.send(player)
	return true
end
extendedEvent:register()

local deathEvent = CreatureEvent("MonkHarmonyDeath")
function deathEvent.onDeath(player)
	spendContexts[player:getId()] = nil
	player:setStorageValue(Harmony.POINTS_STORAGE, 0)
	Harmony.send(player)
	return true
end
deathEvent:register()

local logoutEvent = CreatureEvent("MonkHarmonyLogout")
function logoutEvent.onLogout(player)
	local playerId = player:getId()
	spendContexts[playerId] = nil
	if sereneTimers[playerId] then
		stopEvent(sereneTimers[playerId])
		sereneTimers[playerId] = nil
	end
	player:setStorageValue(Harmony.POINTS_STORAGE, 0)
	player:setStorageValue(Harmony.SERENE_STORAGE, -1)
	return true
end
logoutEvent:register()
