local function getSkillId(skillName)
	skillName = skillName:trim():lower()

	if skillName == "club" then
		return SKILL_CLUB
	elseif skillName == "sword" then
		return SKILL_SWORD
	elseif skillName == "axe" then
		return SKILL_AXE
	elseif skillName == "mining" then
		return SKILL_MINING
	elseif skillName == "crafting" then
		return SKILL_CRAFTING
	elseif skillName == "woodcutting" then
		return SKILL_WOODCUTTING
	elseif skillName == "herbalist" then
		return SKILL_HERBALIST
	elseif skillName == "armorsmith" then
		return SKILL_ARMORSMITH
	elseif skillName == "weaponsmith" then
		return SKILL_WEAPONSMITH
	elseif skillName == "jewelsmith" then
		return SKILL_JEWELSMITH
	elseif skillName:sub(1, 4) == "dist" then
		return SKILL_DISTANCE
	elseif skillName:sub(1, 6) == "shield" then
		return SKILL_SHIELD
	elseif skillName:sub(1, 4) == "fish" then
		return SKILL_FISHING
	elseif skillName:sub(1, 4) == "fist" then
		return SKILL_FIST
	elseif skillName:sub(1, 1) == "m" then
		return SKILL_MAGLEVEL
	elseif skillName == "level" or skillName:sub(1, 1) == "l" or skillName:sub(1, 1) == "e" then
		return SKILL_LEVEL
	end

	return nil
end

-- Accepts both "/addskill player skill amount" and "/addskill player,skill,amount".
-- Character names may contain spaces, so the layout keeps the name as free text
-- and the skill/amount as the trailing tokens.
local function parseParam(param)
	return splitTalkParam(param, "name word n")
end

local function getDisplayValue(target, skillId)
	if skillId == SKILL_LEVEL then
		return target:getLevel()
	elseif skillId == SKILL_MAGLEVEL then
		return target:getMagicLevel()
	end
	return target:getSkillLevel(skillId)
end

local usage = "Usage: /addskill <player> <skill> <amount>  or  /addskill <player>,<skill>,<amount>"

function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		player:sendCancelMessage("You need a god account to use this command.")
		return false
	end

	local split = parseParam(param)
	if not split or not split[1] or split[1]:trim() == "" then
		player:sendCancelMessage(usage)
		return false
	end

	if not split[2] or split[2]:trim() == "" then
		player:sendCancelMessage(usage)
		return false
	end

	local target = Player(split[1]:trim())
	if not target then
		player:sendCancelMessage("A player with that name is not online.")
		return false
	end

	local skillName = split[2]:trim()
	local skillId = getSkillId(skillName)
	if not skillId then
		player:sendCancelMessage("Unknown skill '" .. skillName .. "'.")
		return false
	end

	local count = 1
	if split[3] and split[3]:trim() ~= "" then
		count = tonumber(split[3])
	end

	if not count then
		player:sendCancelMessage("The amount must be a number.")
		return false
	end

	if count == 0 then
		player:sendCancelMessage("The amount must not be 0.")
		return false
	end

	local before = getDisplayValue(target, skillId)
	target:addSkill(skillId, count)
	local after = getDisplayValue(target, skillId)

	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format(
		"%s: %s changed from %d to %d (requested %s).",
		target:getName(), skillName, before, after, tostring(count)))

	if target ~= player then
		target:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format(
			"Your %s was changed from %d to %d by %s.",
			skillName, before, after, player:getName()))
	end

	return false
end
