-- /points ... - acredita monedas de los tres sistemas de progresion.
--
--   /points task    Task Board: Bounty Points, Soulseals, Hunting Task Points
--   /points wheel   Wheel of Destiny: Lesser / Greater Exalted Fragments
--   /points upgrade Character Upgrades: Upgrade Points
--   /points orb     Exalted Orbs (item 29855)
--
-- Sintaxis:  /points <familia> <sub> <n> [personaje]
-- El personaje debe estar online para que su ventana se refresque.

local UPGRADE_TOTAL_KEY = 716544
local UPGRADE_SPENDABLE_KEY = 716545
local EXALTED_ORB_ID = 29855

local WHEEL_LESSER = 84
local WHEEL_GREATER = 85

local PROMOTED_BY_BASE = { [1] = 5, [2] = 6, [3] = 7, [4] = 8, [9] = 10, [11] = 12 }

local TASK_LABELS = {
	bounty = "Bounty Points",
	soulseal = "Soulseals",
	hunting = "Hunting Task Points"
}

local WHEEL_LABELS = {
	lesser = "Lesser Exalted Fragments",
	greater = "Greater Exalted Fragments"
}

local USAGE = table.concat({
	"/points                                     ayuda",
	"/points info [personaje]                   estado de todas las monedas",
	"/points task bounty|soulseal|hunting|all <n> [personaje]",
	"/points wheel lesser|greater|all <n> [personaje]",
	"/points wheel fix [personaje]               premium + vocacion promocionada",
	"/points upgrade <n> [personaje]             Character Upgrades points",
	"/points orb <n> [personaje]                 Exalted Orbs (29855)"
}, "\n")

local function say(player, text)
	player:sendTextMessage(MESSAGE_INFO_DESCR, text)
end

local function bad(player, text)
	player:sendCancelMessage(text)
	return false
end

local function comma(value)
	local formatted = tostring(math.floor(tonumber(value) or 0))
	local k
	repeat
		formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", "%1.%2")
	until k == 0
	return formatted
end

local function signed(amount)
	amount = math.floor(tonumber(amount) or 0)
	if amount == 0 then
		return "0"
	end
	return (amount > 0 and "+" or "-") .. comma(math.abs(amount))
end

local function tokenize(param)
	local tokens = {}
	for token in (param or ""):gmatch("%S+") do
		tokens[#tokens + 1] = token
	end
	return tokens
end

local function tokensFrom(tokens, first)
	local out = {}
	for i = first, #tokens do
		out[#out + 1] = tokens[i]
	end
	return out
end

local function resolveTarget(player, name)
	name = (name or ""):trim()
	if name == "" then
		return player
	end

	local target = Player(name)
	if not target then
		return nil, "A player with that name is not online."
	end
	return target
end

local function taskCreditOne(target, currency, amount)
	if currency == "bounty" then
		if amount >= 0 then
			TaskBoard.addBountyPoints(target, amount)
			return true, TaskBoard.getBountyPoints(target)
		end
		return TaskBoard.removeBountyPoints(target, -amount), TaskBoard.getBountyPoints(target)
	elseif currency == "soulseal" then
		if amount >= 0 then
			TaskBoard.addSoulsealPoints(target, amount)
			return true, TaskBoard.getSoulsealPoints(target)
		end
		return TaskBoard.removeSoulsealPoints(target, -amount), TaskBoard.getSoulsealPoints(target)
	elseif currency == "hunting" or currency == "task" then
		if amount >= 0 then
			TaskBoard.addTaskTokens(target, amount)
			return true, TaskBoard.getTaskTokens(target)
		end
		return TaskBoard.removeTaskTokens(target, -amount), TaskBoard.getTaskTokens(target)
	end
	return nil
end

local handlers = {}

handlers.info = function(player, tokens)
	local target, err = resolveTarget(player, table.concat(tokens, " "))
	if not target then
		return bad(player, err)
	end

	local vocation = target:getVocation()
	local premiumEnds = target:getPremiumEndsAt()
	say(player, string.format("%s | level %d | %s | %s",
		target:getName(), target:getLevel(), vocation:getName(),
		premiumEnds > os.time() and ("premium hasta " .. os.date("%Y-%m-%d", premiumEnds)) or "sin premium"))

	say(player, string.format("Task Board: %s Bounty | %s Soulseals | %s Hunting Task",
		comma(TaskBoard.getBountyPoints(target)),
		comma(TaskBoard.getSoulsealPoints(target)),
		comma(TaskBoard.getTaskTokens(target))))

	local total, levelPoints, extraPoints, used, maxPoints = WheelOfDestiny.getPoints(target)
	local blocks = WheelOfDestiny.getBlocks(target)
	if #blocks == 0 then
		say(player, string.format(
			"Wheel of Destiny: %s disponibles / %s usados de %s (nivel %d -> %s, bonus grade IV -> %s)",
			comma(total - used), comma(used), comma(maxPoints), target:getLevel(),
			comma(levelPoints), comma(extraPoints)))
	else
		say(player, "Wheel of Destiny: BLOQUEADO (" .. table.concat(blocks, ", ") .. ")")
	end

	say(player, string.format("Wheel fragments: %s Lesser / %s Greater",
		comma(WheelOfDestiny.getFragments(target, WHEEL_LESSER)),
		comma(WheelOfDestiny.getFragments(target, WHEEL_GREATER))))

	say(player, string.format("Character Upgrades: %s gastables / %s totales | %d Exalted Orbs",
		comma(getPlayerSpendablePoints(target)), comma(getPlayerTotalPoints(target)),
		target:getItemCount(EXALTED_ORB_ID)))
	return true
end

handlers.task = function(player, tokens)
	local currency = tokens[1] and tokens[1]:lower() or ""
	local amount = tonumber(tokens[2])
	if not amount then
		return bad(player, "Usage: /points task bounty|soulseal|hunting|all <n> [personaje]")
	end

	local target, err = resolveTarget(player, table.concat(tokensFrom(tokens, 3), " "))
	if not target then
		return bad(player, err)
	end

	local list
	if currency == "all" then
		list = { "bounty", "soulseal", "hunting" }
	elseif TASK_LABELS[currency] then
		list = { currency }
	else
		return bad(player, "Unknown currency '" .. currency .. "'. Use bounty, soulseal, hunting or all.")
	end

	local messages = {}
	for _, key in ipairs(list) do
		local ok, balance = taskCreditOne(target, key, amount)
		if ok == nil then
			return bad(player, "Unknown currency '" .. tostring(key) .. "'.")
		end
		if not ok then
			return bad(player, string.format("Not enough %s (current: %s).", TASK_LABELS[key], comma(balance)))
		end
		messages[#messages + 1] = string.format("%s = %s (%s)", TASK_LABELS[key], comma(balance), signed(amount))
	end

	TaskBoard.sendState(target)
	say(player, string.format("%s -> %s", target:getName(), table.concat(messages, " | ")))
	return true
end

handlers.wheel = function(player, tokens)
	local sub = tokens[1] and tokens[1]:lower() or ""

	if sub == "fix" then
		local target, err = resolveTarget(player, table.concat(tokensFrom(tokens, 2), " "))
		if not target then
			return bad(player, err)
		end

		local now = os.time()
		local ends = target:getPremiumEndsAt()
		if ends < now then
			ends = now
		end
		ends = ends + 365 * 86400
		target:setPremiumEndsAt(ends)

		local applied = { "premium hasta " .. os.date("%Y-%m-%d", ends) }
		local vocationId = target:getVocation():getId()
		local promoted = PROMOTED_BY_BASE[vocationId]
		if promoted then
			target:setVocation(promoted)
			applied[#applied + 1] = "vocacion " .. vocationId .. " -> " .. promoted
		end

		WheelOfDestiny.refresh(target)

		local blocks = WheelOfDestiny.getBlocks(target)
		if #blocks == 0 then
			local total, levelPoints, extraPoints, used, maxPoints = WheelOfDestiny.getPoints(target)
			say(player, string.format("%s es elegible: %s disponibles / %s usados de %s (nivel %d -> %s)",
				target:getName(), comma(total - used), comma(used), comma(maxPoints),
				target:getLevel(), comma(levelPoints)))
		else
			say(player, "Wheel of Destiny sigue bloqueado: " .. table.concat(blocks, ", "))
		end
		say(player, "Aplicado: " .. table.concat(applied, ", "))
		return true
	end

	local amount = tonumber(tokens[2])
	if not amount then
		return bad(player, "Usage: /points wheel lesser|greater|all <n> [personaje]  or  /points wheel fix [personaje]")
	end

	local target, err = resolveTarget(player, table.concat(tokensFrom(tokens, 3), " "))
	if not target then
		return bad(player, err)
	end

	local list
	if sub == "all" then
		list = { "lesser", "greater" }
	elseif WHEEL_LABELS[sub] then
		list = { sub }
	else
		return bad(player, "Unknown fragment '" .. tostring(sub) .. "'. Use lesser, greater or all.")
	end

	local messages = {}
	for _, key in ipairs(list) do
		local resourceType = key == "lesser" and WHEEL_LESSER or WHEEL_GREATER
		local balance = WheelOfDestiny.addFragments(target, resourceType, amount)
		messages[#messages + 1] = string.format("%s = %s (%s)", WHEEL_LABELS[key], comma(balance), signed(amount))
	end

	WheelOfDestiny.refresh(target)
	say(player, string.format("%s -> %s", target:getName(), table.concat(messages, " | ")))
	return true
end

handlers.upgrade = function(player, tokens)
	local amount = tonumber(tokens[1])
	if not amount then
		return bad(player, "Usage: /points upgrade <n> [personaje]")
	end

	local target, err = resolveTarget(player, table.concat(tokensFrom(tokens, 2), " "))
	if not target then
		return bad(player, err)
	end

	initializePlayerPoints(target)
	local total = math.max(0, getPlayerTotalPoints(target) + amount)
	local spendable = math.max(0, getPlayerSpendablePoints(target) + amount)
	target:setStorageValue(UPGRADE_TOTAL_KEY, total)
	target:setStorageValue(UPGRADE_SPENDABLE_KEY, spendable)
	gameUpgradesUpdatePoints(target)

	say(player, string.format("%s -> Character Upgrades: %s gastables / %s totales (%s)",
		target:getName(), comma(spendable), comma(total), signed(amount)))
	return true
end

handlers.orb = function(player, tokens)
	local amount = math.floor(tonumber(tokens[1]) or 0)
	if amount <= 0 then
		return bad(player, "Usage: /points orb <n> [personaje]")
	end

	local target, err = resolveTarget(player, table.concat(tokensFrom(tokens, 2), " "))
	if not target then
		return bad(player, err)
	end

	target:addItem(EXALTED_ORB_ID, amount)
	say(player, string.format("%s -> %d Exalted Orbs en el inventario (%d en total).",
		target:getName(), amount, target:getItemCount(EXALTED_ORB_ID)))
	return true
end

function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		player:sendCancelMessage("You need a god account to use this command.")
		return false
	end

	param = (param or ""):trim()
	if param == "" then
		say(player, USAGE)
		return false
	end

	local tokens = tokenize(param)
	local family = tokens[1]:lower()
	local handler = handlers[family]
	if not handler then
		return bad(player, "Unknown family '" .. family .. "'.\n" .. USAGE)
	end

	local ok, err = pcall(handler, player, tokensFrom(tokens, 2))
	if not ok then
		print("[Points] /points " .. family .. " failed: " .. tostring(err))
		return bad(player, "Command failed: " .. tostring(err))
	end

	return false
end
