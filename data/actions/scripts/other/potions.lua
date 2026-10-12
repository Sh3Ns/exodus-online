---- POTIONS WITH COOLDOWN ---
---- EDIT BELOW: local cooldown = 10, 10 = Seconds, change it to the number you want
---- Replace file on data/actions/scripts/other/potions.lua



local berserk = Condition(CONDITION_ATTRIBUTES)
berserk:setParameter(CONDITION_PARAM_TICKS, 10 * 60 * 1000)
berserk:setParameter(CONDITION_PARAM_SKILL_MELEE, 5)
berserk:setParameter(CONDITION_PARAM_SKILL_SHIELD, -10)
berserk:setParameter(CONDITION_PARAM_BUFF_SPELL, true)

local mastermind = Condition(CONDITION_ATTRIBUTES)
mastermind:setParameter(CONDITION_PARAM_TICKS, 10 * 60 * 1000)
mastermind:setParameter(CONDITION_PARAM_STAT_MAGICPOINTS, 3)
mastermind:setParameter(CONDITION_PARAM_BUFF_SPELL, true)

local bullseye = Condition(CONDITION_ATTRIBUTES)
bullseye:setParameter(CONDITION_PARAM_TICKS, 10 * 60 * 1000)
bullseye:setParameter(CONDITION_PARAM_SKILL_DISTANCE, 5)
bullseye:setParameter(CONDITION_PARAM_SKILL_SHIELD, -10)
bullseye:setParameter(CONDITION_PARAM_BUFF_SPELL, true)

local potions = {
	[6558] = { -- concentrated demonic blood
		transform = {7588, 7589},
		effect = CONST_ME_DRAWBLOOD
	},
	[7439] = { -- berserk potion
		condition = berserk,
		vocations = {4, 8, 11, 12},
		effect = CONST_ME_MAGIC_RED,
		description = "Only knights may drink this potion.",
		text = "You feel stronger."
	},
	[7440] = { -- mastermind potion
		condition = mastermind, 
		vocations = {1, 2, 5, 6, 9, 10},
		effect = CONST_ME_MAGIC_BLUE,
		description = "Only sorcerers, druids and illusionists may drink this potion.",
		text = "You feel smarter."
		},
	[7443] = { -- bullseye potion
		condition = bullseye,
		vocations = {3, 7},
		effect = CONST_ME_MAGIC_GREEN,
		description = "Only paladins may drink this potion.",
		text = "You feel more accurate."
	},
	[7588] = { -- strong health potion
		health = {250, 350},
		vocations = {3, 4, 7, 8, 11, 12},
		level = 50,
		flask = 7634,
		description = "Only knights, paladins and monks of level 50 or above may drink this fluid."
	},
	[7589] = { -- strong mana potion
		mana = {115, 185},
		vocations = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12},
		level = 50,
		flask = 7634,
		description = "Only sorcerers, druids, paladins, knights, monks and illusionists of level 50 or above may drink this fluid."
	},
	[7590] = { -- great mana potion
		mana = {150, 250},
		vocations = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12},
		level = 80,
		flask = 7635,
		description = "Only druids, sorcerers, paladins, knights, monks and illusionists of level 80 or above may drink this fluid."
	},
	[7591] = { -- great health potion
		health = {425, 575},
		vocations = {4, 8, 11, 12},
		level = 80,
		flask = 7635,
		description = "Only knights and monks of level 80 or above may drink this fluid."
	},
	[7618] = { -- health potion
		health = {125, 175},
		flask = 7636
	},
	[7620] = { -- mana potion
		mana = {75, 125},
		flask = 7636
	},
	[8472] = { -- great spirit potion
		health = {250, 350},
		mana = {100, 200},
		vocations = {3, 7, 11, 12},
		level = 80,
		flask = 7635,
		description = "Only paladins of level 80 or above may drink this fluid."
	},
	[8473] = { -- ultimate health potion
		health = {650, 850},
		vocations = {4, 8, 11, 12},
		level = 130,
		flask = 7635,
		description = "Only knights and monks of level 130 or above may drink this fluid."
	},
	[8474] = { -- antidote potion
		antidote = true,
		flask = 7636,
	},
	[8704] = { -- small health potion
		health = {60, 90},
		flask = 7636,
	},
	[26029] = { -- ultimate mana potion
		mana = {425, 575},
		vocations = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12},
		level = 130,
		flask = 7635,
		description = "Only druids, sorcerers, paladins, knights, monks and illusionists of level 130 or above may drink this fluid."
	},
	[26030] = { -- ultimate spirit potion
		health = {420, 580},
		mana = {200, 350},
		vocations = {3, 7, 11, 12},
		level = 130,
		flask = 7635,
		description = "Only paladins of level 130 or above may drink this fluid."
	},
	[26031] = { -- supreme health potion
		health = {875, 1125},
		vocations = {4, 8, 11, 12},
		level = 200,
		flask = 7635,
		description = "Only knights and monks of level 200 or above may drink this fluid."
	},
	[26733] = { -- nimble life potion
		health = {515, 685},
		vocations = {3, 4, 7, 8, 11, 12},
		level = 100,
		description = "Only knights, monks and paladins of level 100 or above may drink this fluid."
	},
	[26734] = { -- hazel life potion
		health = {750, 920},
		vocations = {3, 4, 7, 8, 11, 12},
		level = 150,
		description = "Only knights, monks and paladins of level 150 or above may drink this fluid."
	},
	[26735] = { -- tumble life potion
		health = {890, 1050},
		vocations = {3, 4, 7, 8, 11, 12},
		level = 200,
		description = "Only knights and monks of level 200 or above may drink this fluid."
	},
	[26736] = { -- nimble mana potion
		mana = {570, 775},
		vocations = {1, 2, 5, 6, 9, 10},
		level = 100,
		description = "Only sorcerers, druids and illusionists of level 100 or above may drink this fluid."
	},
	[26737] = { -- hazel mana potion
		mana = {750, 885},
		vocations = {1, 2, 3, 5, 6, 7, 9, 10},
		level = 150,
		description = "Only sorcerers, druids, paladins and illusionists of level 150 or above may drink this fluid."
	},
	[26738] = { -- tumble mana potion
		mana = {890, 1050},
		vocations = {1, 2, 5, 6, 9, 10},
		level = 200,
		description = "Only druids, sorcerers and illusionists of level 200 or above may drink this fluid."
	},
	[28076] = { -- Exalted Health potion
		health = {1000, 1180},
		vocations = {3, 4, 7, 8, 11, 12},
		level = 250,
		description = "Only knights, monks and paladins of level 250 or above may drink this fluid."
	},
	[28077] = { -- Advanced Health potion
		health = {1150, 1300},
		vocations = {3, 4, 7, 8, 11, 12},
		level = 350,
		description = "Only knights, monks and paladins of level 350 or above may drink this fluid."
	},
	[28078] = { -- Divine health potion
		health = {1300, 1450},
		vocations = {4, 8, 11, 12},
		level = 500,
		description = "Only knights and monks of level 500 or above may drink this fluid."
	},
	[28079] = { -- Mythic Health potion
		health = {1500, 1650},
		vocations = {4, 8, 11, 12},
		level = 700,
		description = "Only knights and monks of level 700 or above may drink this fluid."
	},
	[28080] = { -- Exalted Mana potion
		mana = {1050, 1150},
		vocations = {1, 2, 3, 5, 6, 7, 9, 10},
		level = 250,
		description = "Only sorcerers, druids, paladins and illusionists of level 250 or above may drink this fluid."
	},
	[28081] = { -- Advanced Mana potion
		mana = {1150, 1280},
		vocations = {1, 2, 5, 6, 9, 10},
		level = 350,
		description = "Only druids, sorcerers and illusionists of level 350 or above may drink this fluid."
	},
	[28082] = { -- Divine Mana potion
		mana = {1280, 1390},
		vocations = {1, 2, 5, 6, 9, 10},
		level = 500,
		description = "Only druids, sorcerers and illusionists of level 500 or above may drink this fluid."
	},
	[28083] = { -- Mythic Mana potion
		mana = {1400, 1600},
		vocations = {1, 2, 5, 6, 9, 10},
		level = 700,
		description = "Only druids, sorcerers and illusionists of level 700 or above may drink this fluid."
	},
	[28085] = { -- Nimble Spirit Potion
		health = {500, 680},
		mana = {240, 380},
		vocations = {3, 7, 11, 12},
		level = 100,
		description = "Only paladins and monks of level 100 or above may drink this fluid."
	},
	[28086] = { -- hazel spirit potion
		health = {550, 720},
		mana = {270, 430},
		vocations = {3, 7, 11, 12},
		level = 150,
		description = "Only paladins and monks of level 150 or above may drink this fluid."
	},
	[28087] = { -- tumble spirit potion
		health = {600, 760},
		mana = {300, 480},
		vocations = {3, 7, 11, 12},
		level = 200,
		description = "Only paladins and monks of level 200 or above may drink this fluid."
	},
	[28088] = { -- exalted spirit potion
		health = {650, 800},
		mana = {330, 530},
		vocations = {3, 7, 11, 12},
		level = 250,
		description = "Only paladins and monks of level 250 or above may drink this fluid."
	},
	[28089] = { -- advanced spirit potion
		health = {750, 890},
		mana = {400, 600},
		vocations = {3, 7, 11, 12},
		level = 350,
		description = "Only paladins and monks of level 350 or above may drink this fluid."
	},
	[28090] = { -- divine spirit potion
		health = {830, 970},
		mana = {480, 680},
		vocations = {3, 7},
		level = 500,
		description = "Only paladins of level 500 or above may drink this fluid."
	},
	[28091] = { -- mythic spirit potion
		health = {920, 1150},
		mana = {570, 850},
		vocations = {3, 7},
		level = 700,
		description = "Only paladins of level 700 or above may drink this fluid."
	},
}


function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if type(target) == "userdata" and not target:isPlayer() then
		return false
	end

	local potion = potions[item:getId()]
	if potion.level and player:getLevel() < potion.level or potion.vocations and not table.contains(potion.vocations, player:getVocation():getId()) then
		player:say(potion.description, TALKTYPE_MONSTER_SAY)
		return true
	end

	local alchemistSaved = false
	if not potion.transform and type(_G.GemsSocket_advancedShouldSavePotion) == "function" then
		alchemistSaved = _G.GemsSocket_advancedShouldSavePotion(player) == true
	end

	local socketPotionModifier = nil
	if not potion.transform and type(_G.GemsSocket_advancedOnUsePotion) == "function" then
		socketPotionModifier = _G.GemsSocket_advancedOnUsePotion(player, target, potion) or nil
	end

	local function applySocketPotionPercent(range, percent)
		if type(range) ~= "table" then
			return range
		end
		percent = math.max(0, tonumber(percent) or 0)
		if percent <= 0 then
			return range
		end
		return {
			math.floor(range[1] * (1 + (percent / 100))),
			math.floor(range[2] * (1 + (percent / 100)))
		}
	end

	if potion.condition then
		player:addCondition(potion.condition)
		player:say(potion.text, TALKTYPE_MONSTER_SAY)
		playSoundPlayer(player, "other_potion.ogg")
		player:getPosition():sendMagicEffect(potion.effect)
	elseif potion.transform then
		local reward = potion.transform[math.random(#potion.transform)]
		if fromPosition.x == CONTAINER_POSITION then
			local targetContainer = Container(item:getParent().uid)
			targetContainer:addItem(reward, 1)
		else
			Game.createItem(reward, 1, fromPosition)
		end
		item:getPosition():sendMagicEffect(potion.effect)
		playSoundPlayer(player, "other_potion.ogg")
		item:remove(1)
		return true
	else
		if potion.health then
			local healthRange = applySocketPotionPercent(potion.health, socketPotionModifier and socketPotionModifier.healthPercent or 0)
			doTargetCombat(player, target, COMBAT_HEALING, healthRange[1], healthRange[2])
			if socketPotionModifier and (socketPotionModifier.mirrorSipPercent or 0) > 0 then
				local averageHeal = math.floor((healthRange[1] + healthRange[2]) / 2)
				local manaAmount = math.max(1, math.floor(averageHeal * (socketPotionModifier.mirrorSipPercent / 100)))
				if target and target.addMana then
					target:addMana(manaAmount)
				end
			end
			playSoundPlayer(player, "health_potion.ogg")
		end

		if potion.mana then
			local manaRange = applySocketPotionPercent(potion.mana, socketPotionModifier and socketPotionModifier.manaPercent or 0)
			doTargetCombat(player, target, COMBAT_MANADRAIN, manaRange[1], manaRange[2])
			playSoundPlayer(player, "mana_potion.ogg")
		end

		if potion.antidote then
			target:removeCondition(CONDITION_POISON)
			playSoundPlayer(player, "other_potion.ogg")
		end

		player:addAchievementProgress("Potion Addict", 100000)
		if not alchemistSaved then
			player:addItem(potion.flask)
		end
		target:say("Aaaah...", TALKTYPE_MONSTER_SAY)
		target:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
	end

	if alchemistSaved then
		return true
	end

	if not configManager.getBoolean(configKeys.REMOVE_POTION_CHARGES) then
		return true
	end

	item:remove(1)
	return true
end
