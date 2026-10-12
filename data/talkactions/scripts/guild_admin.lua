-- /guild <subcomando> ...
-- Administracion del sistema Guild Hall: acredita monedas, sube niveles,
-- edita rangos y permisos. Solo cuentas tipo GOD.
--
-- Sintaxis:  /guild [#<guildId|nombre>] <sub> <args...>

local PERMS = {
	{ key = "INVITE_MEMBERS", bit = 0, label = "Invite Members" },
	{ key = "EDIT_MEMBERS", bit = 1, label = "Edit Members" },
	{ key = "EDIT_ROLES", bit = 2, label = "Edit Ranks" },
	{ key = "EDIT_SETTINGS", bit = 3, label = "Edit Settings" },
	{ key = "MANAGE_GOLD", bit = 4, label = "Manage Gold" },
	{ key = "MANAGE_PERKS", bit = 5, label = "Manage Perks" },
	{ key = "DEPOSIT_STORAGE", bit = 7, label = "Deposit Storage" },
	{ key = "WITHDRAW_STORAGE", bit = 8, label = "Withdraw Storage" },
	{ key = "MANAGE_PRISM", bit = 9, label = "Manage Prism" },
	{ key = "MANAGE_DYNASTIE", bit = 10, label = "Edit Dynasty" }
}

local GUILD_MAX_LEVEL = 10000

local USAGE = table.concat({
	"/guild [#guild] <sub> ...   (el selector '#id' va antes del subcomando)",
	"  info                      estado del guild",
	"  list                      lista de guilds con su id",
	"  all <n>                   oro + premium + tokens + exp + contribucion",
	"  gold <n>                  banco de oro de la guild",
	"  gpp <n>                   banco de premium points de la guild",
	"  tokens <n>                dynasty tokens de la guild",
	"  exp <n>                   experiencia de guild (sube de nivel sola)",
	"  level <n>                 fija el nivel de la guild",
	"  contrib <n>               contribucion total de oro",
	"  pcontrib <n>              contribucion total de premium points",
	"  dynlevel <n>              nivel de dinastia",
	"  dynexp <n>                experiencia de dinastia",
	"  pp <n> [personaje]        premium points de la cuenta",
	"  perk <id> <nivel>         fija el nivel de un perk de guild",
	"  roles                     permisos de cada rango",
	"  rankperm <rankId> <perm|all|none> [perm...]"
}, "\n")

local function say(player, text)
	player:sendTextMessage(MESSAGE_INFO_DESCR, text)
end

local function bad(player, text)
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, text)
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

local function loadGuild(guildId)
	guildId = tonumber(guildId) or 0
	if guildId <= 0 then
		return nil
	end

	local query = db.storeQuery(table.concat({
		"SELECT `id`, `name`, `ownerid`, `guild_level`, `guild_experience`,",
		"`balance`, `contribution`, `premium_balance`, `premium_contribution`,",
		"`dynastie_tokens`, `dynastie_level`, `dynastie_experience`, `perks`",
		"FROM `guilds` WHERE `id` = " .. guildId
	}, " "))
	if not query then
		return nil
	end

	local row = {
		id = result.getNumber(query, "id"),
		name = result.getString(query, "name"),
		ownerid = result.getNumber(query, "ownerid"),
		guild_level = result.getNumber(query, "guild_level"),
		guild_experience = result.getNumber(query, "guild_experience"),
		balance = result.getNumber(query, "balance"),
		contribution = result.getNumber(query, "contribution"),
		premium_balance = result.getNumber(query, "premium_balance"),
		premium_contribution = result.getNumber(query, "premium_contribution"),
		dynastie_tokens = result.getNumber(query, "dynastie_tokens"),
		dynastie_level = result.getNumber(query, "dynastie_level"),
		dynastie_experience = result.getNumber(query, "dynastie_experience"),
		perks = result.getString(query, "perks")
	}
	result.free(query)
	return row
end

local function guildLevelProgress(level, exp)
	level = math.max(1, tonumber(level) or 1)
	exp = math.max(0, tonumber(exp) or 0)
	local base = GuildManagement.NEXT_LEVEL_BASE

	while level < GUILD_MAX_LEVEL do
		local required = math.max(base, level * base)
		if exp < required then
			return level, exp, required
		end
		exp = exp - required
		level = level + 1
	end

	return level, exp, math.max(base, level * base)
end

local function requiredExpFor(level)
	local base = GuildManagement.NEXT_LEVEL_BASE
	return math.max(base, math.max(1, tonumber(level) or 1) * base)
end

local function updateGuild(guildId, sets)
	if #sets == 0 then
		return true
	end
	return db.query("UPDATE `guilds` SET " .. table.concat(sets, ", ") .. " WHERE `id` = " .. guildId)
end

local function resolveGuildId(player, selector)
	if selector and selector ~= "" then
		local asNumber = tonumber(selector)
		if asNumber then
			return loadGuild(asNumber) and asNumber or 0
		end

		local query = db.storeQuery("SELECT `id` FROM `guilds` WHERE LOWER(`name`) = LOWER(" .. escape(selector) .. ") LIMIT 1")
		if not query then
			return 0
		end
		local guildId = result.getNumber(query, "id")
		result.free(query)
		return guildId
	end

	local guild = player:getGuild()
	return guild and guild:getId() or 0
end

local function findPlayerByName(name)
	local query = db.storeQuery("SELECT `id`, `name`, `account_id` FROM `players` WHERE LOWER(`name`) = LOWER(" .. escape(name) .. ") LIMIT 1")
	if not query then
		return nil
	end
	local data = {
		id = result.getNumber(query, "id"),
		name = result.getString(query, "name"),
		accountId = result.getNumber(query, "account_id")
	}
	result.free(query)
	return data
end

local function permissionBits(list)
	local bits = 0
	for _, name in ipairs(list) do
		local found = nil
		for _, perm in ipairs(PERMS) do
			if perm.key:lower() == name:lower() then
				found = perm
				break
			end
		end
		if not found then
			return nil, name
		end
		bits = bits + (2 ^ found.bit)
	end
	return math.floor(bits)
end

local function describePermissions(bits)
	bits = tonumber(bits) or 0
	if bits < 0 then
		return "ALL (lider)"
	end

	local names = {}
	for _, perm in ipairs(PERMS) do
		if math.floor(bits / (2 ^ perm.bit)) % 2 == 1 then
			names[#names + 1] = perm.key
		end
	end
	if #names == 0 then
		return "ninguno"
	end
	return table.concat(names, " | ")
end

local function pushState(guildId, player)
	if GuildHallRefresh then
		GuildHallRefresh(guildId)
	end
	if player then
		sendGuildPayload(player, "selfBalance", {
			balance = player:getBankBalance(),
			premiumPoints = getAccountPremiumPoints(player:getAccountId())
		})
	end
end

local function requireGuild(player, selector)
	local guildId = resolveGuildId(player, selector)
	if guildId <= 0 then
		bad(player, selector and ("Guild '" .. selector .. "' not found.") or "You are not in a guild.")
		return nil
	end

	local guild = loadGuild(guildId)
	if not guild then
		bad(player, "Guild data could not be loaded.")
		return nil
	end

	return guildId, guild
end

local handlers = {}

handlers.help = function(player, selector, args)
	say(player, USAGE)
	return true
end

handlers.info = function(player, selector, args)
	local guildId, guild = requireGuild(player, selector)
	if not guildId then
		return false
	end

	local leader = nil
	local query = db.storeQuery("SELECT `name` FROM `players` WHERE `id` = " .. guild.ownerid)
	if query then
		leader = result.getString(query, "name")
		result.free(query)
	end

	say(player, string.format("Guild #%d  %s", guild.id, guild.name))
	say(player, string.format("Leader: %s   Level: %d   Exp: %s / %s",
		leader or "?", guild.guild_level, comma(guild.guild_experience), comma(requiredExpFor(guild.guild_level))))
	say(player, string.format("Gold bank: %s   Premium bank: %s   Dynasty tokens: %s",
		comma(guild.balance), comma(guild.premium_balance), comma(guild.dynastie_tokens)))
	say(player, string.format("Contribution: %s   Premium contribution: %s",
		comma(guild.contribution), comma(guild.premium_contribution)))
	say(player, string.format("Dynasty: level %d   exp %s",
		guild.dynastie_level, comma(guild.dynastie_experience)))
	return true
end

handlers.list = function(player, selector, args)
	local query = db.storeQuery("SELECT `id`, `name`, `guild_level` FROM `guilds` ORDER BY `id`")
	if not query then
		return bad(player, "There are no guilds.")
	end

	repeat
		say(player, string.format("#%d  %-24s level %d",
			result.getNumber(query, "id"),
			result.getString(query, "name"),
			result.getNumber(query, "guild_level")))
	until not result.next(query)
	result.free(query)
	return true
end

local function credit(player, selector, args, sub, label, column)
	local amount = tonumber(args[1])
	if not amount or amount == 0 then
		return bad(player, "Usage: /guild " .. sub .. " <amount>")
	end

	local guildId, guild = requireGuild(player, selector)
	if not guildId then
		return false
	end

	if not updateGuild(guildId, { "`" .. column .. "` = GREATEST(0, `" .. column .. "` + " .. amount .. ")" }) then
		return bad(player, "Failed to update the guild.")
	end

	pushState(guildId, player)
	local after = math.max(0, (tonumber(guild[column]) or 0) + amount)
	say(player, string.format("%s: %s -> %s", label, comma(guild[column]), comma(after)))
	return true
end

handlers.all = function(player, selector, args)
	local amount = tonumber(args[1])
	if not amount or amount == 0 then
		return bad(player, "Usage: /guild all <amount>")
	end

	local guildId, guild = requireGuild(player, selector)
	if not guildId then
		return false
	end

	local level, exp = guildLevelProgress(guild.guild_level, guild.guild_experience + amount)
	local points = math.max(0, getAccountPremiumPoints(player:getAccountId()) + amount)

	local sets = {
		"`balance` = GREATEST(0, `balance` + " .. amount .. ")",
		"`premium_balance` = GREATEST(0, `premium_balance` + " .. amount .. ")",
		"`dynastie_tokens` = GREATEST(0, `dynastie_tokens` + " .. amount .. ")",
		"`contribution` = GREATEST(0, `contribution` + " .. amount .. ")",
		"`premium_contribution` = GREATEST(0, `premium_contribution` + " .. amount .. ")",
		"`guild_level` = " .. level,
		"`guild_experience` = " .. exp
	}

	if not updateGuild(guildId, sets) then
		return bad(player, "Failed to update the guild.")
	end

	setAccountPremiumPoints(player:getAccountId(), points)
	pushState(guildId, player)

	say(player, string.format("Credited %s to %s: gold, premium, tokens, exp and contribution. Account premium points: %s",
		comma(amount), guild.name, comma(points)))
	if level ~= guild.guild_level then
		say(player, string.format("Guild leveled up: %d -> %d", guild.guild_level, level))
	end
	return true
end

handlers.gold = function(player, selector, args)
	return credit(player, selector, args, "gold", "Guild gold bank", "balance")
end

handlers.gpp = function(player, selector, args)
	return credit(player, selector, args, "gpp", "Guild premium bank", "premium_balance")
end

handlers.tokens = function(player, selector, args)
	return credit(player, selector, args, "tokens", "Dynasty tokens", "dynastie_tokens")
end

handlers.contrib = function(player, selector, args)
	return credit(player, selector, args, "contrib", "Contribution", "contribution")
end

handlers.pcontrib = function(player, selector, args)
	return credit(player, selector, args, "pcontrib", "Premium contribution", "premium_contribution")
end

handlers.exp = function(player, selector, args)
	local amount = tonumber(args[1])
	if not amount or amount == 0 then
		return bad(player, "Usage: /guild exp <amount>")
	end

	local guildId, guild = requireGuild(player, selector)
	if not guildId then
		return false
	end

	local level, exp = guildLevelProgress(guild.guild_level, guild.guild_experience + amount)
	if not updateGuild(guildId, { "`guild_level` = " .. level, "`guild_experience` = " .. exp }) then
		return bad(player, "Failed to update the guild.")
	end

	pushState(guildId, player)
	say(player, string.format("Guild exp: %d/%d -> %d/%d (level %d)",
		guild.guild_experience, requiredExpFor(guild.guild_level), exp, requiredExpFor(level), level))
	if level ~= guild.guild_level then
		say(player, string.format("Guild leveled up: %d -> %d", guild.guild_level, level))
	end
	return true
end

handlers.level = function(player, selector, args)
	local level = tonumber(args[1])
	if not level or level < 1 then
		return bad(player, "Usage: /guild level <nivel>")
	end

	local guildId, guild = requireGuild(player, selector)
	if not guildId then
		return false
	end

	level = math.min(GUILD_MAX_LEVEL, level)
	if not updateGuild(guildId, { "`guild_level` = " .. level, "`guild_experience` = 0" }) then
		return bad(player, "Failed to update the guild.")
	end

	pushState(guildId, player)
	say(player, string.format("Guild %s is now level %d (exp 0 / %s)",
		guild.name, level, comma(requiredExpFor(level))))
	return true
end

handlers.dynlevel = function(player, selector, args)
	local level = tonumber(args[1])
	if not level or level < 1 then
		return bad(player, "Usage: /guild dynlevel <nivel>")
	end

	level = math.max(1, level)
	local guildId, guild = requireGuild(player, selector)
	if not guildId then
		return false
	end

	if not updateGuild(guildId, { "`dynastie_level` = " .. level }) then
		return bad(player, "Failed to update the guild.")
	end

	pushState(guildId, player)
	say(player, string.format("Dynasty level of %s: %d -> %d", guild.name, guild.dynastie_level, level))
	return true
end

handlers.dynexp = function(player, selector, args)
	local amount = tonumber(args[1])
	if not amount or amount == 0 then
		return bad(player, "Usage: /guild dynexp <amount>")
	end

	local guildId, guild = requireGuild(player, selector)
	if not guildId then
		return false
	end

	local level = guild.dynastie_level
	local exp = math.max(0, guild.dynastie_experience + amount)

	if GuildHallDynastie and GuildHallDynastie.calculateLevelProgress then
		level, exp = GuildHallDynastie.calculateLevelProgress(level, exp)
	end

	if not updateGuild(guildId, { "`dynastie_level` = " .. level, "`dynastie_experience` = " .. exp }) then
		return bad(player, "Failed to update the guild.")
	end

	pushState(guildId, player)
	say(player, string.format("Dynasty exp: level %d (%s)", level, comma(exp)))
	return true
end

handlers.pp = function(player, selector, args)
	local amount = tonumber(args[1])
	if not amount or amount == 0 then
		return bad(player, "Usage: /guild pp <amount> [personaje]")
	end

	local accountId = player:getAccountId()
	local targetName = player:getName()

	if args[2] and args[2] ~= "" then
		local data = findPlayerByName(args[2])
		if not data then
			return bad(player, "Player '" .. args[2] .. "' not found.")
		end
		if not data.accountId or data.accountId <= 0 then
			return bad(player, "Player '" .. data.name .. "' has no account.")
		end
		accountId = data.accountId
		targetName = data.name
	end

	local before = getAccountPremiumPoints(accountId)
	local after = math.max(0, before + amount)
	if not setAccountPremiumPoints(accountId, after) then
		return bad(player, "Failed to update premium points.")
	end

	local online = Player(targetName)
	if online then
		sendGuildPayload(online, "selfBalance", {
			balance = online:getBankBalance(),
			premiumPoints = after
		})
	end

	say(player, string.format("Premium points for %s: %s -> %s", targetName, comma(before), comma(after)))
	return true
end

handlers.perk = function(player, selector, args)
	local perkId = tonumber(args[1])
	local newLevel = tonumber(args[2])
	if not perkId or not newLevel then
		return bad(player, "Usage: /guild perk <id> <nivel>")
	end

	local definition = nil
	for _, perk in ipairs(GuildManagement.PERKS) do
		if perk.id == perkId then
			definition = perk
			break
		end
	end
	if not definition then
		return bad(player, "Unknown perk id " .. tostring(perkId) .. ".")
	end

	newLevel = math.max(0, math.min(definition.maxLevel, newLevel))

	local guildId, guild = requireGuild(player, selector)
	if not guildId then
		return false
	end

	local perks = {}
	if guild.perks and guild.perks ~= "" then
		local ok, decoded = pcall(function() return json.decode(guild.perks) end)
		if ok and type(decoded) == "table" then
			perks = decoded
		end
	end
	for _, perk in ipairs(GuildManagement.PERKS) do
		local current = tonumber(perks[tostring(perk.id)] or perks[perk.id] or 0) or 0
		perks[tostring(perk.id)] = math.max(0, math.min(perk.maxLevel, current))
	end
	perks[tostring(perkId)] = newLevel

	if not updateGuild(guildId, { "`perks` = " .. escape(json.encode(perks)) }) then
		return bad(player, "Failed to save guild perks.")
	end

	if GuildHallRefresh then
		GuildHallRefresh(guildId)
	end
	say(player, string.format("%s: '%s' set to level %d / %d", guild.name, definition.name, newLevel, definition.maxLevel))
	return true
end

handlers.roles = function(player, selector, args)
	local guildId = resolveGuildId(player, selector)
	if guildId <= 0 then
		return bad(player, "You are not in a guild.")
	end

	local query = db.storeQuery(table.concat({
		"SELECT `gr`.`id`, `gr`.`name`, `gr`.`level`, `gr`.`permissions`,",
		"(SELECT COUNT(*) FROM `guild_membership` WHERE `guild_id` = `gr`.`guild_id` AND `rank_id` = `gr`.`id`) AS `members`",
		"FROM `guild_ranks` `gr` WHERE `gr`.`guild_id` = " .. guildId,
		"ORDER BY `gr`.`level` DESC, `gr`.`id` DESC"
	}, " "))
	if not query then
		return bad(player, "No ranks found for this guild.")
	end

	repeat
		say(player, string.format("Rank #%d  %-20s level %d  members %d  [%s]",
			result.getNumber(query, "id"),
			result.getString(query, "name"),
			result.getNumber(query, "level"),
			result.getNumber(query, "members"),
			describePermissions(result.getNumber(query, "permissions"))))
	until not result.next(query)
	result.free(query)

	local names = {}
	for _, perm in ipairs(PERMS) do
		names[#names + 1] = perm.key
	end
	say(player, "Permisos: " .. table.concat(names, " "))
	return true
end

handlers.rankperm = function(player, selector, args)
	local rankId = tonumber(args[1])
	if not rankId or not args[2] then
		return bad(player, "Usage: /guild rankperm <rankId> <perm|all|none> [perm...]")
	end

	local guildId = resolveGuildId(player, selector)
	if guildId <= 0 then
		return bad(player, "You are not in a guild.")
	end

	local query = db.storeQuery("SELECT `id`, `name` FROM `guild_ranks` WHERE `id` = " .. rankId .. " AND `guild_id` = " .. guildId)
	if not query then
		return bad(player, "Rank " .. tostring(rankId) .. " does not belong to this guild.")
	end
	local rankName = result.getString(query, "name")
	result.free(query)

	local tokens = {}
	for i = 2, #args do
		tokens[#tokens + 1] = args[i]
	end

	local bits = 0
	if #tokens == 1 and tokens[1]:lower() == "all" then
		bits = -1
	elseif #tokens == 1 and tokens[1]:lower() == "none" then
		bits = 0
	else
		local resolved, unknown = permissionBits(tokens)
		if not resolved then
			return bad(player, "Unknown permission '" .. tostring(unknown) .. "'.")
		end
		bits = resolved
	end

	if not db.query("UPDATE `guild_ranks` SET `permissions` = " .. bits .. " WHERE `id` = " .. rankId .. " AND `guild_id` = " .. guildId) then
		return bad(player, "Failed to update the rank.")
	end

	pushState(guildId, nil)
	say(player, string.format("Rank '%s' (#%d) permissions: %s", rankName, rankId, describePermissions(bits)))
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

	local selector = nil
	local head, rest = param:match("^(%S+)%s*(.*)$")
	if head and head:sub(1, 1) == "#" then
		selector = head:sub(2)
		param = rest
	end

	local sub, tail = param:match("^(%S+)%s*(.*)$")
	sub = (sub or ""):lower()

	local handler = handlers[sub]
	if not handler then
		return bad(player, "Unknown subcommand '" .. sub .. "'.\n" .. USAGE)
	end

	local args = {}
	if tail and tail ~= "" then
		for token in tail:gmatch("%S+") do
			args[#args + 1] = token
		end
	end

	local ok, err = pcall(handler, player, selector, args)
	if not ok then
		print("[GuildAdmin] /guild " .. sub .. " failed: " .. tostring(err))
		return bad(player, "Command failed: " .. tostring(err))
	end

	return false
end
