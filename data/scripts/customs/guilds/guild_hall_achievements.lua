local function create(api)
	local function buildScaledRewards(index, rewardType)
		local rewardSets = {
			-- 10, 25, 50, 100, 200, 500, 1000, 2000, 5000, 10000
			global_player_kill_total = {
				{ gold = 2500, exp = 5500, items = { { itemId = 25172, count = 10 } } },
				{ gold = 5500, exp = 14000, items = { { itemId = 25172, count = 25 } } },
				{ gold = 9500, exp = 22000, items = { { itemId = 25172, count = 50 } } },
				{ gold = 13500, exp = 34000, items = { { itemId = 25377, count = 50 } } },
				{ gold = 21500, exp = 50000, items = { { itemId = 25377, count = 100 } } },
				{ gold = 34000, exp = 88500, items = { { itemId = 25377, count = 200 }, { itemId = 25172, count = 200 } } },
				{ gold = 52500, exp = 145000, items = { { itemId = 26779, count = 15 }, { itemId = 2160, count = 5 } } },
				{ gold = 81300, exp = 218000, items = { { itemId = 26779, count = 30 }, { itemId = 2160, count = 10 } } },
				{ gold = 145000, exp = 320000, items = { { itemId = 26779, count = 60 }, { itemId = 2160, count = 15 } } },
				{ gold = 238000, exp = 450000, items = { { itemId = 26779, count = 120 }, { itemId = 2160, count = 30 } } }
			},
			-- 5000, 10000, 25000, 50000, 100000, 250000, 500000, 1000000, 2500000, 5000000, 10000000
			monster_kill_total = {
				{ gold = 10000, exp = 5000, items = { { itemId = 28343, count = 400 } } },
				{ gold = 20000, exp = 10000, items = { { itemId = 28344, count = 150 } } },
				{ gold = 25000, exp = 25000, items = { { itemId = 28343, count = 800 } } },
				{ gold = 50000, exp = 50000, items = { { itemId = 28344, count = 300 } } },
				{ gold = 100000, exp = 100000, items = { { itemId = 28345, count = 15 } } },
				{ gold = 200000, exp = 200000, items = { { itemId = 28345, count = 30 }, { itemId = 2160, count = 10 } } },
				{ gold = 350000, exp = 350000, items = { { itemId = 28345, count = 60 }, { itemId = 2160, count = 20 } } },
				{ gold = 500000, exp = 500000, items = { { itemId = 28345, count = 100 }, { itemId = 2160, count = 35 } } },
				{ gold = 650000, exp = 650000, items = { { itemId = 28345, count = 180 }, { itemId = 2160, count = 70 } } },
				{ gold = 850000, exp = 850000, items = { { itemId = 28345, count = 280 }, { itemId = 2160, count = 140 } } },
				{ gold = 1300000, exp = 1300000, items = { { itemId = 28345, count = 400 }, { itemId = 2160, count = 250 } } }
			},
			-- 10, 25, 50, 100, 200, 500, 1000
			prism_attack_kill_total = {
				{ gold = 6000, exp = 10000, items = { { itemId = 30272, count = 1 },{ itemId = 30273, count = 1 }, { itemId = 30274, count = 1 }, { itemId = 30275, count = 1 }, { itemId = 30276, count = 1 }, { itemId = 30277, count = 1 }, { itemId = 30278, count = 1 }, { itemId = 30279, count = 1 }, { itemId = 30280, count = 1 }, { itemId = 30281, count = 1 } } },
				{ gold = 9000, exp = 15000, items = { { itemId = 30282, count = 1 }, { itemId = 30283, count = 1 }, { itemId = 30284, count = 1 }, { itemId = 30285, count = 1 }, { itemId = 30286, count = 1 }, { itemId = 30287, count = 1 }, { itemId = 30288, count = 1 }, { itemId = 30289, count = 1 } } },
				{ gold = 14000, exp = 22000, items = { { itemId = 30290, count = 2 }, { itemId = 30291, count = 2 }, { itemId = 30292, count = 2 }, { itemId = 30293, count = 2 }, { itemId = 30294, count = 2 }, { itemId = 30295, count = 2 }, { itemId = 30296, count = 2 }, { itemId = 30297, count = 2 }, { itemId = 30298, count = 2 } } },
				{ gold = 22000, exp = 35000, items = { { itemId = 30299, count = 2 }, { itemId = 30290, count = 2 }, { itemId = 30300, count = 2 }, { itemId = 30301, count = 2 }, { itemId = 30302, count = 2 }, { itemId = 30303, count = 2 }, { itemId = 30304, count = 2 }, { itemId = 30305, count = 2 } } },
				{ gold = 35000, exp = 50000, items = { { itemId = 30341, count = 1 },{ itemId = 30342, count = 1 }, { itemId = 30343, count = 1 }, { itemId = 30344, count = 1 }, { itemId = 30345, count = 1 }, { itemId = 30346, count = 1 }, { itemId = 30278, count = 1 }, { itemId = 30279, count = 1 }, { itemId = 30347, count = 1 }, { itemId = 30348, count = 1 }, { itemId = 30349, count = 1 } } },
				{ gold = 80000, exp = 100000, items = { { itemId = 30351, count = 1 }, { itemId = 30352, count = 1 }, { itemId = 30353, count = 1 }, { itemId = 30354, count = 1 }, { itemId = 30355, count = 1 }, { itemId = 30356, count = 1 } }, { itemId = 30357, count = 1 }, { itemId = 30358, count = 1 } },
				{ gold = 180000, exp = 220000, items = { { itemId = 30390, count = 2 }, { itemId = 30391, count = 2 }, { itemId = 30392, count = 2 }, { itemId = 30393, count = 2 }, { itemId = 30394, count = 2 }, { itemId = 30395, count = 2 }, { itemId = 30396, count = 2 } } }
			},
			-- 10, 25, 50, 100, 200, 500, 1000
			prism_defense_player_kill_total = {
				{ gold = 6000, exp = 10000, items = { { itemId = 30272, count = 1 },{ itemId = 30273, count = 1 }, { itemId = 30274, count = 1 }, { itemId = 30275, count = 1 }, { itemId = 30276, count = 1 }, { itemId = 30277, count = 1 }, { itemId = 30278, count = 1 }, { itemId = 30279, count = 1 }, { itemId = 30280, count = 1 }, { itemId = 30281, count = 1 } } },
				{ gold = 9000, exp = 15000, items = { { itemId = 30282, count = 1 }, { itemId = 30283, count = 1 }, { itemId = 30284, count = 1 }, { itemId = 30285, count = 1 }, { itemId = 30286, count = 1 }, { itemId = 30287, count = 1 }, { itemId = 30288, count = 1 }, { itemId = 30289, count = 1 } } },
				{ gold = 14000, exp = 22000, items = { { itemId = 30290, count = 2 }, { itemId = 30291, count = 2 }, { itemId = 30292, count = 2 }, { itemId = 30293, count = 2 }, { itemId = 30294, count = 2 }, { itemId = 30295, count = 2 }, { itemId = 30296, count = 2 }, { itemId = 30297, count = 2 }, { itemId = 30298, count = 2 } } },
				{ gold = 22000, exp = 35000, items = { { itemId = 30299, count = 2 }, { itemId = 30290, count = 2 }, { itemId = 30300, count = 2 }, { itemId = 30301, count = 2 }, { itemId = 30302, count = 2 }, { itemId = 30303, count = 2 }, { itemId = 30304, count = 2 }, { itemId = 30305, count = 2 } } },
				{ gold = 35000, exp = 50000, items = { { itemId = 30341, count = 1 },{ itemId = 30342, count = 1 }, { itemId = 30343, count = 1 }, { itemId = 30344, count = 1 }, { itemId = 30345, count = 1 }, { itemId = 30346, count = 1 }, { itemId = 30278, count = 1 }, { itemId = 30279, count = 1 }, { itemId = 30347, count = 1 }, { itemId = 30348, count = 1 }, { itemId = 30349, count = 1 } } },
				{ gold = 80000, exp = 100000, items = { { itemId = 30351, count = 1 }, { itemId = 30352, count = 1 }, { itemId = 30353, count = 1 }, { itemId = 30354, count = 1 }, { itemId = 30355, count = 1 }, { itemId = 30356, count = 1 } }, { itemId = 30357, count = 1 }, { itemId = 30358, count = 1 } },
				{ gold = 180000, exp = 220000, items = { { itemId = 30390, count = 2 }, { itemId = 30391, count = 2 }, { itemId = 30392, count = 2 }, { itemId = 30393, count = 2 }, { itemId = 30394, count = 2 }, { itemId = 30395, count = 2 }, { itemId = 30396, count = 2 } } }
			},
			-- 1, 5, 10, 25, 50, 100, 200, 500, 1000
			prism_destroy_total = {
				{ gold = 7000, exp = 11000, items = { { itemId = 27990, count = 1 }, { itemId = 28079, count = 10 }, { itemId = 28083, count = 10 }, { itemId = 28091, count = 10 } } },
				{ gold = 10000, exp = 16000, items = { { itemId = 27990, count = 2 }, { itemId = 28079, count = 20 }, { itemId = 28083, count = 20 }, { itemId = 28091, count = 20 } } },
				{ gold = 15000, exp = 24000, items = { { itemId = 27990, count = 3 }, { itemId = 28079, count = 40 }, { itemId = 28083, count = 40 }, { itemId = 28091, count = 40 } } },
				{ gold = 24000, exp = 36000, items = { { itemId = 27990, count = 4 }, { itemId = 28079, count = 80 }, { itemId = 28083, count = 80 }, { itemId = 28091, count = 80 } } },
				{ gold = 38000, exp = 52000, items = { { itemId = 27990, count = 5 }, { itemId = 28079, count = 160 }, { itemId = 28083, count = 160 }, { itemId = 28091, count = 160 } } },
				{ gold = 85000, exp = 110000, items = { { itemId = 27990, count = 6 }, { itemId = 28079, count = 250 }, { itemId = 28083, count = 250 }, { itemId = 28091, count = 250 } } },
				{ gold = 180000, exp = 220000, items = { { itemId = 27990, count = 7 }, { itemId = 28079, count = 350 }, { itemId = 28083, count = 350 }, { itemId = 28091, count = 350 } } },
				{ gold = 350000, exp = 420000, items = { { itemId = 27990, count = 8 }, { itemId = 28079, count = 500 }, { itemId = 28083, count = 500 }, { itemId = 28091, count = 500 } } },
				{ gold = 700000, exp = 750000, items = { { itemId = 27990, count = 10 }, { itemId = 28079, count = 1000 }, { itemId = 28083, count = 1000 }, { itemId = 28091, count = 1000 } } }
			},
			-- Crafting Skill 50 100 250 500 1000 times crafted
			profession_activity_total = {
				{ gold = 5000, exp = 9000, items = { { itemId = 27703, count = 3 }, { itemId = 27704, count = 3 }, { itemId = 27705, count = 3 } } },
				{ gold = 9000, exp = 15000, items = { { itemId = 27703, count = 5 }, { itemId = 27704, count = 5 }, { itemId = 27705, count = 5 } } },
				{ gold = 16000, exp = 26000, items = { { itemId = 27703, count = 10 }, { itemId = 27704, count = 10 }, { itemId = 27705, count = 10 } } },
				{ gold = 28000, exp = 42000, items = { { itemId = 27699, count = 1 }, { itemId = 27700, count = 1 }, { itemId = 27701, count = 1 }, { itemId = 27702, count = 1 } } },
				{ gold = 50000, exp = 70000, items = { { itemId = 27699, count = 3 }, { itemId = 27700, count = 3 }, { itemId = 27701, count = 3 }, { itemId = 27702, count = 3 } } }
			}
		}

		if type(rewardType) == "string" and rewardType:find("^profession_") then
			rewardType = "profession_activity_total"
		end

		local rewards = rewardSets[rewardType]
		return rewards and rewards[index] or { gold = 0, exp = 0, items = {} }
	end

	local function appendThresholdAchievements(definitions, options)
		local numerals = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX" }
		for index, target in ipairs(options.targets or {}) do
			local rewards = buildScaledRewards(index, options.type)
			if type(options.buildRewards) == "function" then
				rewards = options.buildRewards(index, target, rewards)
			end
			definitions[#definitions + 1] = {
				id = string.format("%s_%d", options.idPrefix, target),
				name = string.format("%s %s", options.namePrefix, numerals[index] or tostring(index)),
				objective = string.format(options.objectiveTemplate, target),
				type = options.type,
				target = target,
				rewards = rewards
			}
		end
	end

	local definitions = {
		{ id = "guild_level_10", name = "Guild Level 10", objective = "Reach guild level 10.", type = "guild_level_reached", target = 10, rewards = { gold = 25000, exp = 300000, items = { } } },
		{ id = "guild_level_20", name = "Guild Level 20", objective = "Reach guild level 20.", type = "guild_level_reached", target = 20, rewards = { gold = 50000, exp = 600000, items = {  } } },
		{ id = "guild_level_30", name = "Guild Level 30", objective = "Reach guild level 30.", type = "guild_level_reached", target = 30, rewards = { gold = 100000, exp = 1200000, items = {  } } },
		{ id = "guild_level_50", name = "Guild Level 50", objective = "Reach guild level 50.", type = "guild_level_reached", target = 50, rewards = { gold = 250000, exp = 2500000, items = {  } } },
		{ id = "guild_level_100", name = "Guild Level 100", objective = "Reach guild level 100.", type = "guild_level_reached", target = 100, rewards = { gold = 500000, exp = 5000000, items = {  } } },
		{ id = "guild_level_200", name = "Guild Level 200", objective = "Reach guild level 200.", type = "guild_level_reached", target = 200, rewards = { gold = 1000000, exp = 10000000, items = {  } } },
		{ id = "guild_level_500", name = "Guild Level 500", objective = "Reach guild level 500.", type = "guild_level_reached", target = 500, rewards = { gold = 2000000, exp = 20000000, items = {  } } },
		{ id = "guild_members_10", name = "Growing Order I", objective = "Reach 10 guild members.", type = "guild_member_count", target = 10, rewards = { gold = 15000, exp = 30000, items = { } } },
		{ id = "guild_members_20", name = "Growing Order II", objective = "Reach 20 guild members.", type = "guild_member_count", target = 20, rewards = { gold = 30000, exp = 60000, items = {  } } },
		{ id = "guild_members_30", name = "Growing Order III", objective = "Reach 30 guild members.", type = "guild_member_count", target = 30, rewards = { gold = 60000, exp = 120000, items = {  } } },
		{ id = "guild_members_50", name = "Growing Order IV", objective = "Reach 50 guild members.", type = "guild_member_count", target = 50, rewards = { gold = 100000, exp = 240000, items = {  } } },
		{ id = "guild_members_100", name = "Growing Order V", objective = "Reach 100 guild members.", type = "guild_member_count", target = 100, rewards = { gold = 150000, exp = 480000, items = { } } },
		{ id = "dynastie_builder_1", name = "Dynasty Founder", objective = "Place 1 dynastie core.", type = "dynastie_place_total", target = 1, rewards = { gold = 15000, exp = 30000, items = { { itemId = 30654, count = 1 } } } },
		{ id = "dynastie_builder_3", name = "Dynasty Founder II", objective = "Place 3 dynastie cores.", type = "dynastie_place_total", target = 3, rewards = { gold = 30000, exp = 50000, items = { { itemId = 30654, count = 2 } } } },
		{ id = "dynastie_builder_5", name = "Dynasty Founder III", objective = "Place 5 dynastie cores.", type = "dynastie_place_total", target = 5, rewards = { gold = 60000, exp = 80000, items = { { itemId = 30654, count = 5 } } } },
		{ id = "dynastie_builder_10", name = "Dynasty Founder IV", objective = "Place 10 dynastie cores.", type = "dynastie_place_total", target = 10, rewards = { gold = 120000, exp = 100000, items = { { itemId = 30654, count = 10 } } } },
		{ id = "gold_donor_50000", name = "Treasurer I", objective = "Donate 50.000 gold to the guild.", type = "gold_contribution_total", target = 50000, rewards = { gold = 3000, exp = 5000, items = { { itemId = 2160, count = 2 } } } },
		{ id = "gold_donor_200000", name = "Treasurer II", objective = "Donate 200.000 gold to the guild.", type = "gold_contribution_total", target = 200000, rewards = { gold = 5000, exp = 10000, items = { { itemId = 2160, count = 8 } } } },
		{ id = "gold_donor_1000000", name = "Treasurer III", objective = "Donate 1.000.000 gold to the guild.", type = "gold_contribution_total", target = 1000000, rewards = { gold = 8000, exp = 18000, items = { { itemId = 2160, count = 40 } } } },
		{ id = "gold_donor_2000000", name = "Treasurer IV", objective = "Donate 2.000.000 gold to the guild.", type = "gold_contribution_total", target = 2000000, rewards = { gold = 12000, exp = 26000, items = { { itemId = 28872, count = 1 } } } },
		{ id = "gold_donor_5000000", name = "Treasurer V", objective = "Donate 5.000.000 gold to the guild.", type = "gold_contribution_total", target = 5000000, rewards = { gold = 20000, exp = 40000, items = { { itemId = 28872, count = 3 } } } },
		{ id = "gold_donor_10000000", name = "Treasurer VI", objective = "Donate 10.000.000 gold to the guild.", type = "gold_contribution_total", target = 10000000, rewards = { gold = 30000, exp = 65000, items = { { itemId = 28872, count = 6 }, { itemId = 2160, count = 20 } } } },
		{ id = "gold_donor_50000000", name = "Treasurer VII", objective = "Donate 50.000.000 gold to the guild.", type = "gold_contribution_total", target = 50000000, rewards = { gold = 40000, exp = 150000, items = { { itemId = 28872, count = 35 } } } },
		{ id = "gold_donor_100000000", name = "Treasurer VIII", objective = "Donate 100.000.000 gold to the guild.", type = "gold_contribution_total", target = 100000000, rewards = { gold = 60000, exp = 300000, items = { { itemId = 28872, count = 70 } } } },
		{ id = "gold_donor_100000000", name = "Treasurer IX", objective = "Donate 250.000.000 gold to the guild.", type = "gold_contribution_total", target = 250000000, rewards = { gold = 90000, exp = 600000, items = { { itemId = 28873, count = 2 } } } },
		{ id = "gold_donor_100000000", name = "Treasurer X", objective = "Donate 500.000.000 gold to the guild.", type = "gold_contribution_total", target = 500000000, rewards = { gold = 130000, exp = 1200000, items = { { itemId = 28873, count = 4 } } } },
		{ id = "gold_donor_100000000", name = "Treasurer XI", objective = "Donate 1.000.000.000 gold to the guild.", type = "gold_contribution_total", target = 1000000000, rewards = { gold = 200000, exp = 2400000, items = { { itemId = 28873, count = 8 } } } },
		{ id = "premium_donor_50", name = "Patron I", objective = "Donate 50 premium points to the guild.", type = "premium_contribution_total", target = 50, rewards = { gold = 50000, exp = 9000, items = { { itemId = 2152, count = 250 } } } },
		{ id = "premium_donor_100", name = "Patron II", objective = "Donate 100 premium points to the guild.", type = "premium_contribution_total", target = 100, rewards = { gold = 90000, exp = 15000, items = { } } },
		{ id = "premium_donor_250", name = "Patron III", objective = "Donate 250 premium points to the guild.", type = "premium_contribution_total", target = 250, rewards = { gold = 150000, exp = 24000, items = { } } },
		{ id = "premium_donor_500", name = "Patron IV", objective = "Donate 500 premium points to the guild.", type = "premium_contribution_total", target = 500, rewards = { gold = 260000, exp = 38000, items = { } } },
		{ id = "premium_donor_1000", name = "Patron V", objective = "Donate 1.000 premium points to the guild.", type = "premium_contribution_total", target = 1000, rewards = { gold = 450000, exp = 65000, items = {  } } },
		{ id = "premium_donor_2000", name = "Patron VI", objective = "Donate 2.000 premium points to the guild.", type = "premium_contribution_total", target = 2000, rewards = { gold = 800000, exp = 110000, items = {  } } },
		{ id = "premium_donor_5000", name = "Patron VII", objective = "Donate 5.000 premium points to the guild.", type = "premium_contribution_total", target = 5000, rewards = { gold = 1800000, exp = 220000, items = {  } } },
		{ id = "premium_donor_10000", name = "Patron VIII", objective = "Donate 10.000 premium points to the guild.", type = "premium_contribution_total", target = 10000, rewards = { gold = 3500000, exp = 400000, items = { } } },
		{ id = "guild_age_30", name = "Legacy I", objective = "Keep the guild alive for 30 days.", type = "guild_age_days", target = 30, rewards = { gold = 15000, exp = 25000, items = { { itemId = 2152, count = 500 } } } },
		{ id = "guild_age_60", name = "Legacy II", objective = "Keep the guild alive for 60 days.", type = "guild_age_days", target = 60, rewards = { gold = 30000, exp = 50000, items = { { itemId = 2160, count = 5 } } } },
		{ id = "guild_age_100", name = "Legacy III", objective = "Keep the guild alive for 100 days.", type = "guild_age_days", target = 100, rewards = { gold = 60000, exp = 100000, items = { { itemId = 28872, count = 3 } } } },
		{ id = "guild_age_200", name = "Legacy IV", objective = "Keep the guild alive for 200 days.", type = "guild_age_days", target = 200, rewards = { gold = 120000, exp = 500000, items = { { itemId = 28872, count = 6 } } } },
		{ id = "guild_age_365", name = "Legacy V", objective = "Keep the guild alive for 365 days.", type = "guild_age_days", target = 365, rewards = { gold = 240000, exp = 1000000, items = { { itemId = 28872, count = 20 } } } },
		{ id = "guild_age_730", name = "Legacy VI", objective = "Keep the guild alive for 2 years.", type = "guild_age_days", target = 730, rewards = { gold = 480000, exp = 3000000, items = { { itemId = 28873, count = 1 } } } },
		{ id = "guild_age_1825", name = "Legacy VII", objective = "Keep the guild alive for 5 years.", type = "guild_age_days", target = 1825, rewards = { gold = 960000, exp = 10000000, items = { { itemId = 28873, count = 5 } } } },
		{ id = "guild_age_3650", name = "Legacy VIII", objective = "Keep the guild alive for 10 years.", type = "guild_age_days", target = 3650, rewards = { gold = 1920000, exp = 50000000, items = { { itemId = 28873, count = 50 } } } },
		{ id = "prism_builder_10", name = "Prism Builder I", objective = "Place 10 guild prisms.", type = "prism_place_total", target = 10, rewards = { gold = 5000, exp = 15000, items = { { itemId = 30657, count = 5 } } } },
		{ id = "prism_builder_50", name = "Prism Builder II", objective = "Place 50 guild prisms.", type = "prism_place_total", target = 50, rewards = { gold = 12500, exp = 30000, items = { { itemId = 30657, count = 15 } } } },
		{ id = "prism_builder_100", name = "Prism Builder III", objective = "Place 100 guild prisms.", type = "prism_place_total", target = 100, rewards = { gold = 20000, exp = 60000, items = { { itemId = 30657, count = 25 } } } },
		{ id = "prism_builder_200", name = "Prism Builder IV", objective = "Place 200 guild prisms.", type = "prism_place_total", target = 200, rewards = { gold = 35000, exp = 90000, items = { { itemId = 30657, count = 40 } } } },
		{ id = "quest_master_50", name = "Quest Master I", objective = "Complete 50 guild quests.", type = "quest_claim_total", target = 50, rewards = { gold = 10000, exp = 25000, items = { { itemId = 28365, count = 2 } } } },
		{ id = "quest_master_100", name = "Quest Master II", objective = "Complete 100 guild quests.", type = "quest_claim_total", target = 100, rewards = { gold = 17500, exp = 35000, items = { { itemId = 28366, count = 2 } } } },
		{ id = "quest_master_200", name = "Quest Master III", objective = "Complete 200 guild quests.", type = "quest_claim_total", target = 200, rewards = { gold = 25000, exp = 60000, items = { { itemId = 28367, count = 2 } } } },
		{ id = "quest_master_500", name = "Quest Master IV", objective = "Complete 500 guild quests.", type = "quest_claim_total", target = 500, rewards = { gold = 45000, exp = 95000, items = { { itemId = 28368, count = 2 } } } },
		{ id = "quest_master_1000", name = "Quest Master V", objective = "Complete 1000 guild quests.", type = "quest_claim_total", target = 1000, rewards = { gold = 75000, exp = 150000, items = { { itemId = 28369, count = 2 }} } },
		{ id = "quest_master_1000", name = "Quest Master VI", objective = "Complete 2000 guild quests.", type = "quest_claim_total", target = 2000, rewards = { gold = 75000, exp = 150000, items = { { itemId = 28370, count = 2 }} } },
		{ id = "prism_rarity_common", name = "Prism Appraiser I", objective = "Obtain a Common equipment item from collected prism loot.", type = "prism_collect_rarity_common", target = 1, rewards = { gold = 4000, exp = 6000, items = { { itemId = 29619, count = 50 } } } },
		{ id = "prism_rarity_uncommon", name = "Prism Appraiser II", objective = "Obtain an Uncommon equipment item from collected prism loot.", type = "prism_collect_rarity_uncommon", target = 1, rewards = { gold = 7000, exp = 10000, items = { { itemId = 29620, count = 50 } } } },
		{ id = "prism_rarity_rare", name = "Prism Appraiser III", objective = "Obtain a Rare equipment item from collected prism loot.", type = "prism_collect_rarity_rare", target = 1, rewards = { gold = 12000, exp = 18000, items = { { itemId = 29621, count = 50 } } } },
		{ id = "prism_rarity_epic", name = "Prism Appraiser IV", objective = "Obtain an Epic equipment item from collected prism loot.", type = "prism_collect_rarity_epic", target = 1, rewards = { gold = 22000, exp = 32000, items = { { itemId = 29622, count = 50 } } } },
		{ id = "prism_rarity_legendary", name = "Prism Appraiser V", objective = "Obtain a Legendary equipment item from collected prism loot.", type = "prism_collect_rarity_legendary", target = 1, rewards = { gold = 45000, exp = 65000, items = { { itemId = 29845, count = 10 } } } },
		{ id = "prism_rarity_exotic", name = "Prism Appraiser VI", objective = "Obtain an Exotic equipment item from collected prism loot.", type = "prism_collect_rarity_exotic", target = 1, rewards = { gold = 65000, exp = 90000, items = { { itemId = 29846, count = 10 } } } },
		{ id = "prism_rarity_mythic", name = "Prism Appraiser VII", objective = "Obtain a Mythic equipment item from collected prism loot.", type = "prism_collect_rarity_mythic", target = 1, rewards = { gold = 90000, exp = 125000, items = { { itemId = 29847, count = 10 } } } },
		{ id = "prism_rarity_chaos", name = "Prism Appraiser VIII", objective = "Obtain a Chaos equipment item from collected prism loot.", type = "prism_collect_rarity_chaos", target = 1, rewards = { gold = 120000, exp = 165000, items = { { itemId = 29848, count = 10 } } } },
		{ id = "prism_rarity_eternal", name = "Prism Appraiser IX", objective = "Obtain an Eternal equipment item from collected prism loot.", type = "prism_collect_rarity_eternal", target = 1, rewards = { gold = 160000, exp = 220000, items = { { itemId = 29849, count = 10 } } } },
		{ id = "prism_rarity_divine", name = "Prism Appraiser X", objective = "Obtain a Divine equipment item from collected prism loot.", type = "prism_collect_rarity_divine", target = 1, rewards = { gold = 220000, exp = 300000, items = { { itemId = 29850, count = 10 } } } },
		{ id = "prism_rarity_phantasmal", name = "Prism Appraiser XI", objective = "Obtain a Phantasmal equipment item from collected prism loot.", type = "prism_collect_rarity_phantasmal", target = 1, rewards = { gold = 300000, exp = 400000, items = { { itemId = 29851, count = 50 }, { itemId = 29852, count = 50 } } } },
		{ id = "prism_rarity_celestial", name = "Prism Appraiser XII", objective = "Obtain a Celestial equipment item from collected prism loot.", type = "prism_collect_rarity_celestial", target = 1, rewards = { gold = 400000, exp = 520000, items = { { itemId = 29853, count = 50 }, { itemId = 29854, count = 50 } } } },
		{ id = "prism_rarity_cosmic", name = "Prism Appraiser XIII", objective = "Obtain a Cosmic equipment item from collected prism loot.", type = "prism_collect_rarity_cosmic", target = 1, rewards = { gold = 520000, exp = 680000, items = { { itemId = 29855, count = 50 }, { itemId = 29856, count = 50 } } } },
		{ id = "prism_rarity_abyssal", name = "Prism Appraiser XIV", objective = "Obtain an Abyssal equipment item from collected prism loot.", type = "prism_collect_rarity_abyssal", target = 1, rewards = { gold = 700000, exp = 900000, items = { { itemId = 29857, count = 15 }, { itemId = 29858, count = 7 } } } },
		{ id = "prism_rarity_transcendent", name = "Prism Appraiser XV", objective = "Obtain a Transcendent equipment item from collected prism loot.", type = "prism_collect_rarity_transcendent", target = 1, rewards = { gold = 1000000, exp = 1250000, items = { { itemId = 29859, count = 5 } } } }
	}

	appendThresholdAchievements(definitions, {
		idPrefix = "prism_collect_gold",
		namePrefix = "Prism Treasury",
		objectiveTemplate = "Obtain %d gold from collected prisms.",
		type = "prism_collect_gold_total",
		targets = { 20000, 50000, 100000, 250000, 500000, 1000000, 2500000, 10000000 },
		buildRewards = function(index)
			local rewardSets = {
				{ gold = 25000, exp = 15000, items = { } },
				{ gold = 55000, exp = 30000, items = { } },
				{ gold = 110000, exp = 60000, items = {  } },
				{ gold = 260000, exp = 120000, items = {  } },
				{ gold = 500000, exp = 240000, items = {  } },
				{ gold = 1000000, exp = 480000, items = {  } },
				{ gold = 2500000, exp = 960000, items = {  } },
				{ gold = 5000000, exp = 1920000, items = {  } }
			}
			return rewardSets[index] or { gold = 0, exp = 0, items = {} }
		end
	})
	appendThresholdAchievements(definitions, {
		idPrefix = "prism_collect_exp",
		namePrefix = "Prism Wisdom",
		objectiveTemplate = "Obtain %d guild experience from collected prisms.",
		type = "prism_collect_exp_total",
		targets = { 5000, 10000, 25000, 50000, 100000, 250000, 500000, 1000000, 2000000, 5000000 },
		buildRewards = function(index)
			local rewardSets = {
				{ gold = 4000, exp = 7000, items = {  } },
				{ gold = 6500, exp = 11000, items = {  } },
				{ gold = 10000, exp = 17000, items = {  } },
				{ gold = 16000, exp = 26000, items = {  } },
				{ gold = 26000, exp = 42000, items = {  } },
				{ gold = 48000, exp = 76000, items = {  } },
				{ gold = 90000, exp = 140000, items = {  } },
				{ gold = 180000, exp = 260000, items = { { itemId = 30657, count = 3 } } },
				{ gold = 320000, exp = 450000, items = { { itemId = 30657, count = 5 } } },
				{ gold = 700000, exp = 900000, items = { { itemId = 30657, count = 8 } } }
			}
			return rewardSets[index] or { gold = 0, exp = 0, items = {} }
		end
	})

	appendThresholdAchievements(definitions, {
		idPrefix = "guild_monster_kill",
		namePrefix = "Monster Hunt",
		objectiveTemplate = "Kill %d monsters with guild members anywhere in the world.",
		type = "monster_kill_total",
		targets = { 5000, 10000, 25000, 50000, 100000, 250000, 500000, 1000000, 2500000, 5000000, 10000000 }
	})
	appendThresholdAchievements(definitions, {
		idPrefix = "guild_player_kill",
		namePrefix = "Bloodbound",
		objectiveTemplate = "Kill %d players with guild members anywhere in the world.",
		type = "global_player_kill_total",
		targets = { 10, 25, 50, 100, 200, 500, 1000, 2000, 5000, 10000 }
	})
	appendThresholdAchievements(definitions, {
		idPrefix = "prism_attack_kill",
		namePrefix = "Prism Assault",
		objectiveTemplate = "Kill %d players while attacking guild prisms.",
		type = "prism_attack_kill_total",
		targets = { 10, 25, 50, 100, 200, 500, 1000 }
	})
	appendThresholdAchievements(definitions, {
		idPrefix = "prism_defense_kill",
		namePrefix = "Prism Bastion",
		objectiveTemplate = "Kill %d players while defending guild prisms.",
		type = "prism_defense_player_kill_total",
		targets = { 10, 25, 50, 100, 200, 500, 1000 }
	})
	appendThresholdAchievements(definitions, {
		idPrefix = "prism_destroy",
		namePrefix = "Prism Breaker",
		objectiveTemplate = "Destroy %d guild prisms.",
		type = "prism_destroy_total",
		targets = { 1, 5, 10, 25, 50, 100, 200, 500, 1000 }
	})
	appendThresholdAchievements(definitions, {
		idPrefix = "profession_mining",
		namePrefix = "Mining",
		objectiveTemplate = "Complete %d successful mining actions.",
		type = "profession_mining_total",
		targets = { 50, 100, 250, 500, 1000 }
	})
	appendThresholdAchievements(definitions, {
		idPrefix = "profession_herbalist",
		namePrefix = "Herbalist",
		objectiveTemplate = "Complete %d successful herbalist harvests.",
		type = "profession_herbalist_total",
		targets = { 50, 100, 250, 500, 1000 }
	})
	appendThresholdAchievements(definitions, {
		idPrefix = "profession_woodcutting",
		namePrefix = "Woodcutting",
		objectiveTemplate = "Complete %d successful woodcutting actions.",
		type = "profession_woodcutting_total",
		targets = { 50, 100, 250, 500, 1000 }
	})
	appendThresholdAchievements(definitions, {
		idPrefix = "profession_fishing",
		namePrefix = "Fishing",
		objectiveTemplate = "Complete %d successful fishing actions.",
		type = "profession_fishing_total",
		targets = { 50, 100, 250, 500, 1000 }
	})
	appendThresholdAchievements(definitions, {
		idPrefix = "profession_crafting",
		namePrefix = "Crafting",
		objectiveTemplate = "Complete %d successful crafting actions.",
		type = "profession_crafting_total",
		targets = { 50, 100, 250, 500, 1000 }
	})
	appendThresholdAchievements(definitions, {
		idPrefix = "profession_armorsmith",
		namePrefix = "Armorsmith",
		objectiveTemplate = "Complete %d successful armorsmith crafts.",
		type = "profession_armorsmith_total",
		targets = { 50, 100, 250, 500, 1000 }
	})
	appendThresholdAchievements(definitions, {
		idPrefix = "profession_weaponsmith",
		namePrefix = "Weaponsmith",
		objectiveTemplate = "Complete %d successful weaponsmith crafts.",
		type = "profession_weaponsmith_total",
		targets = { 50, 100, 250, 500, 1000 }
	})
	appendThresholdAchievements(definitions, {
		idPrefix = "profession_jewelsmith",
		namePrefix = "Jewelsmith",
		objectiveTemplate = "Complete %d successful jewelsmith crafts.",
		type = "profession_jewelsmith_total",
		targets = { 50, 100, 250, 500, 1000 }
	})

	definitions[#definitions + 1] = { id = "boss_yirkas_blue_scales_trio", name = "Yirkas Blue Scales Triumvirate", objective = "Kill Yirkas Blue Scales with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "yirkas blue scales", target = 1, minGuildMembers = 2, rewards = { gold = 15000, exp = 25000, items = {  } } }
	definitions[#definitions + 1] = { id = "boss_drume_trio", name = "Drume Triumvirate", objective = "Kill Drume with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "drume", target = 1, minGuildMembers = 2, rewards = { gold = 15000, exp = 25000, items = {  } } }
	definitions[#definitions + 1] = { id = "boss_katex_blood_tongue_trio", name = "Katex Blood Tongue Triumvirate", objective = "Kill Katex Blood Tongue with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "katex blood tongue", target = 1, minGuildMembers = 2, rewards = { gold = 15000, exp = 25000, items = { } } }
	definitions[#definitions + 1] = { id = "boss_utua_stone_sting_trio", name = "Utua Stone Sting Triumvirate", objective = "Kill Utua Stone Sting with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "utua stone sting", target = 1, minGuildMembers = 2, rewards = { gold = 15000, exp = 25000, items = { } } }
	definitions[#definitions + 1] = { id = "boss_grand_master_oberon_trio", name = "Grand Master Oberon Triumvirate", objective = "Kill Grand Master Oberon with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "grand master oberon", target = 1, minGuildMembers = 2, rewards = { gold = 15000, exp = 25000, items = {  } } }
	definitions[#definitions + 1] = { id = "boss_irgix_the_flimsy_trio", name = "Irgix the Flimsy Triumvirate", objective = "Kill Irgix the Flimsy with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "irgix the flimsy", target = 1, minGuildMembers = 2, rewards = { gold = 15000, exp = 25000, items = { } } }
	definitions[#definitions + 1] = { id = "boss_lokathmor_trio", name = "Lokathmor Triumvirate", objective = "Kill Lokathmor with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "lokathmor", target = 1, minGuildMembers = 2, rewards = { gold = 15000, exp = 25000, items = { { itemId = 7419, count = 1 }, { itemId = 2656, count = 1 }, { itemId = 5904, count = 3 } } } }
	definitions[#definitions + 1] = { id = "boss_mazzinor_trio", name = "Mazzinor Triumvirate", objective = "Kill Mazzinor with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "mazzinor", target = 1, minGuildMembers = 2, rewards = { gold = 45000, exp = 60000, items = { { itemId = 8878, count = 1 }, { itemId = 7404, count = 1 }, { itemId = 5954, count = 5 }, } } }
	definitions[#definitions + 1] = { id = "boss_scarlett_etzel_trio", name = "Scarlett Etzel Triumvirate", objective = "Kill Scarlett Etzel with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "scarlett etzel", target = 1, minGuildMembers = 2, rewards = { gold = 15000, exp = 25000, items = { { itemId = 27213, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_the_dread_maiden_trio", name = "The Dread Maiden Triumvirate", objective = "Kill 10 times The Dread Maiden with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "the dread maiden", target = 10, minGuildMembers = 2, rewards = { gold = 50000, exp = 85000, items = { { itemId = 27295, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_the_fear_feaster_trio", name = "The Fear Feaster Triumvirate", objective = "Kill 10 times The Fear Feaster with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "the fear feaster", target = 10, minGuildMembers = 2, rewards = { gold = 50000, exp = 85000, items = { { itemId = 27297, count = 4 } } } }
	definitions[#definitions + 1] = { id = "boss_the_pale_worm_trio", name = "The Pale Worm Triumvirate", objective = "Kill 10 times The Pale Worm with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "the pale worm", target = 10, minGuildMembers = 2, rewards = { gold = 50000, exp = 85000, items = { { itemId = 27286, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_the_scourge_of_oblivion_trio", name = "The Scourge of Oblivion Triumvirate", objective = "Kill 3 times The Scourge of Oblivion with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "the scourge of oblivion", target = 3, minGuildMembers = 2, rewards = { gold = 50000, exp = 85000, items = { { itemId = 29947, count = 1 }, { itemId = 25382, count = 1 }, { itemId = 27188, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_the_unwelcome_trio", name = "The Unwelcome Triumvirate", objective = "Kill 10 times The Unwelcome with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "the unwelcome", target = 10, minGuildMembers = 2, rewards = { gold = 50000, exp = 85000, items = { { itemId = 27287, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_unaz_the_mean_trio", name = "Unaz the Mean Triumvirate", objective = "Kill Unaz the Mean with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "unaz the mean", target = 1, minGuildMembers = 2, rewards = { gold = 15000, exp = 25000, items = {  } } }
	definitions[#definitions + 1] = { id = "boss_urmahlullu_the_weakened_trio", name = "Urmahlullu The Weakened Triumvirate", objective = "Kill 10 times Urmahlullu The Weakened with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "urmahlullu the weakened", target = 10, minGuildMembers = 2, rewards = { gold = 50000, exp = 85000, items = { { itemId = 29989, count = 1 }, { itemId = 27264, count = 1},  { itemId = 27265, count = 1 }, { itemId = 27266, count = 1 }, { itemId = 27267, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_vok_the_freakish_trio", name = "Vok the Freakish Triumvirate", objective = "Kill Vok the Freakish with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "vok the freakish", target = 1, minGuildMembers = 2, rewards = { gold = 15000, exp = 25000, items = {  } } }
	definitions[#definitions + 1] = { id = "boss_ferumbras_mortal_shell_trio", name = "Ferumbras Mortal Shell Triumvirate", objective = "Kill 5 times Ferumbras Mortal Shell with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "ferumbras mortal shell", target = 5, minGuildMembers = 2, rewards = { gold = 80000, exp = 125000, items = { { itemId = 2522, count = 1 }, { itemId = 7435, count = 1 }, { itemId = 7411, count = 1 }, { itemId = 2539, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_bakragore_trio", name = "Bakragore Triumvirate", objective = "Kill 10 times Bakragore with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "bakragore", target = 1, minGuildMembers = 2, rewards = { gold = 80000, exp = 125000, items = { { itemId = 27446, count = 2 } } } }
	definitions[#definitions + 1] = { id = "boss_chagorz_trio", name = "Chagorz Triumvirate", objective = "Kill 10 times Chagorz with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "chagorz", target = 10, minGuildMembers = 2, rewards = { gold = 65000, exp = 95000, items = { { itemId = 15489, count = 1 }, { itemId = 8882, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_ichgahal_trio", name = "Ichgahal Triumvirate", objective = "Kill Ichgahal with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "ichgahal", target = 1, minGuildMembers = 2, rewards = { gold = 65000, exp = 95000, items = { { itemId = 2505, count = 1 }, { itemId = 15491, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_murcion_trio", name = "Murcion Triumvirate", objective = "Kill Murcion with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "murcion", target = 1, minGuildMembers = 2, rewards = { gold = 65000, exp = 95000, items = { { itemId = 8857, count = 1 }, { itemId = 2421, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_vemiath_trio", name = "Vemiath Triumvirate", objective = "Kill Vemiath with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "vemiath", target = 1, minGuildMembers = 2, rewards = { gold = 65000, exp = 95000, items = { { itemId = 8881, count = 1 }, { itemId = 21690, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_brokul_trio", name = "Brokul Triumvirate", objective = "Kill 2 times Brokul with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "brokul", target = 2, minGuildMembers = 2, rewards = { gold = 15000, exp = 25000, items = { { itemId = 27193, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_king_zelos_trio", name = "King Zelos Triumvirate", objective = "Kill 10 times King Zelos with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "king zelos", target = 10, minGuildMembers = 2, rewards = { gold = 80000, exp = 125000, items = { { itemId = 29976, count = 1 }, { itemId = 27231, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_gulosh_trio", name = "Gulosh Triumvirate", objective = "Kill 10 times Gulosh with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "gulosh", target = 10, minGuildMembers = 2, rewards = { gold = 45000, exp = 60000, items = { { itemId = 7412, count = 1 }, { itemId = 27184, count = 20 } } } }
	definitions[#definitions + 1] = { id = "boss_gorzindel_trio", name = "Gorzindel Triumvirate", objective = "Kill 10 times Gorzindel with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "gorzindel", target = 10, minGuildMembers = 2, rewards = { gold = 45000, exp = 60000, items = { { itemId = 8901, count = 1 }, { itemId = 2645, count = 1 }, { itemId = 25377, count = 20 } } } }
	definitions[#definitions + 1] = { id = "boss_abyssador_trio", name = "Abyssador Triumvirate", objective = "Kill 5 times Abyssador with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "abyssador", target = 5, minGuildMembers = 2, rewards = { gold = 75000, exp = 95000, items = { { itemId = 18452, count = 1 }, { itemId = 18454, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_deathstrike_trio", name = "Deathstrike Triumvirate", objective = "Kill 5 times Deathstrike with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "deathstrike", target = 5, minGuildMembers = 2, rewards = { gold = 75000, exp = 95000, items = { { itemId = 18453, count = 1 }, { itemId = 18450, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_deep_terror_trio", name = "Deep terror Triumvirate", objective = "Kill 5 times Deep terror with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "deep terror", target = 5, minGuildMembers = 2, rewards = { gold = 75000, exp = 95000, items = { { itemId = 18465, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_gnomevil_trio", name = "Gnomevil Triumvirate", objective = "Kill 5 times Gnomevil with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "gnomevil", target = 5, minGuildMembers = 2, rewards = { gold = 75000, exp = 95000, items = { { itemId = 18451, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_plagirath_trio", name = "Plagirath Triumvirate", objective = "Kill 5 times Plagirath with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "plagirath", target = 5, minGuildMembers = 2, rewards = { gold = 15000, exp = 25000, items = { { itemId = 25522, count = 1 }, { itemId = 25523, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_azure_trio", name = "Azure Triumvirate", objective = "Kill 2 times Azure with 2 guild players nearby and obtain a Guild Mount: Glacial Wraithling.", type = "boss_kill_with_guild", monster = "azure", target = 2, minGuildMembers = 2, guildMountId = 151, rewards = { gold = 15000, exp = 25000, items = { { itemId = 25522, count = 1 }, { itemId = 25523, count = 1 } }, mount = "Glacial Wraithling" } }
	definitions[#definitions + 1] = { id = "boss_ushuriel_trio", name = "Ushuriel Triumvirate", objective = "Kill 3 times Ushuriel with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "ushuriel", target = 3, minGuildMembers = 2, rewards = { gold = 30000, exp = 45000, items = { { itemId = 7391, count = 1 }, { itemId = 7417, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_jaul_trio", name = "Jaul Triumvirate", objective = "Kill 10 times Jaul with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "jaul", target = 10, minGuildMembers = 2, rewards = { gold = 65000, exp = 85000, items = { { itemId = 15412, count = 1 }, { itemId = 15413, count = 1 }, { itemId = 15414, count = 1 }, { itemId = 15410, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_mawhawk_trio", name = "Mawhawk Triumvirate", objective = "Kill 5 times Mawhawk with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "mawhawk", target = 5, minGuildMembers = 2, rewards = { gold = 45000, exp = 45000, items = { { itemId = 22396, count = 10 }, { itemId = 22397, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_omrafir_trio", name = "Omrafir Triumvirate", objective = "Kill Omrafir with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "omrafir", target = 1, minGuildMembers = 2, rewards = { gold = 60000, exp = 75000, items = { { itemId = 22608, count = 1 }, { itemId = 22612, count = 5} } } }
	definitions[#definitions + 1] = { id = "boss_morgaroth_trio", name = "Morgaroth Triumvirate", objective = "Kill 3 times Morgaroth with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "morgaroth", target = 3, minGuildMembers = 2, rewards = { gold = 65000, exp = 85000, items = { { itemId = 8850, count = 1 }, { itemId = 8851, count = 1 }, { itemId = 8852, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_crustacea_gigantica_trio", name = "Crustacea Gigantica Triumvirate", objective = "Kill Crustacea Gigantica with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "crustacea gigantica", target = 1, minGuildMembers = 2, rewards = { gold = 15000, exp = 25000, items = { } } }
	definitions[#definitions + 1] = { id = "boss_orshabaal_trio", name = "Orshabaal Triumvirate", objective = "Kill 3 times Orshabaal with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "orshabaal", target = 3, minGuildMembers = 2, rewards = { gold = 45000, exp = 65000, items = { { itemId = 8890, count = 1 }, { itemId = 3955, count = 20 } } } }
	definitions[#definitions + 1] = { id = "boss_midnight_panther_trio", name = "Midnight Panther Triumvirate", objective = "Kill 5 times Midnight Panther with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "midnight panther", target = 5, minGuildMembers = 2, rewards = { gold = 15000, exp = 25000, items = { { itemId = 18511, count = 2 } } } }
	definitions[#definitions + 1] = { id = "boss_zulazza_the_corruptor_trio", name = "Zulazza the Corruptor Triumvirate", objective = "Kill 3 times Zulazza the Corruptor with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "zulazza the corruptor", target = 3, minGuildMembers = 2, rewards = { gold = 35000, exp = 40000, items = { { itemId = 8891, count = 1 }, { itemId = 11118, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_chizzoron_the_distorter_trio", name = "Chizzoron the Distorter Triumvirate", objective = "Kill 3 times Chizzoron the Distorter with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "chizzoron the distorter", target = 3, minGuildMembers = 2, rewards = { gold = 35000, exp = 45000, items = { { itemId = 2169, count = 3 }, { itemId = 9971, count = 1 }, { itemId = 7441, count = 5 }  } } }
	definitions[#definitions + 1] = { id = "boss_ghazbaran_trio", name = "Ghazbaran Triumvirate", objective = "Kill 3 times Ghazbaran with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "ghazbaran", target = 3, minGuildMembers = 2, rewards = { gold = 55000, exp = 65000, items = { { itemId = 29978, count = 1 }, { itemId = 8887, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_aquatic_overlord_thalassa_trio", name = "Aquatic Overlord Thalassa Triumvirate", objective = "Kill Aquatic Overlord Thalassa with 3 guild players nearby.", type = "boss_kill_with_guild", monster = "aquatic overlord thalassa", target = 1, minGuildMembers = 3, rewards = { gold = 80000, exp = 150000, items = { { itemId = 28033, count = 2 }, { itemId = 28057, count = 1 }, { itemId = 27642, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_azazel_the_infernal_seraph_trio", name = "Azazel The Infernal Seraph Triumvirate", objective = "Kill Azazel The Infernal Seraph with 3 guild players nearby.", type = "boss_kill_with_guild", monster = "azazel the infernal seraph", target = 1, minGuildMembers = 3, rewards = { gold = 80000, exp = 150000, items = { { itemId = 28033, count = 2 }, { itemId = 28057, count = 1 }, { itemId = 27643, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_dreadbone_the_eternal_trio", name = "Dreadbone The Eternal Triumvirate", objective = "Kill Dreadbone The Eternal with 3 guild players nearby.", type = "boss_kill_with_guild", monster = "dreadbone the eternal", target = 1, minGuildMembers = 3, rewards = { gold = 80000, exp = 150000, items = { { itemId = 28033, count = 2 }, { itemId = 28057, count = 1 }, { itemId = 27644, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_dreadscale_the_ancient_trio", name = "Dreadscale The Ancient Triumvirate", objective = "Kill Dreadscale The Ancient with 3 guild players nearby.", type = "boss_kill_with_guild", monster = "dreadscale the ancient", target = 1, minGuildMembers = 3, rewards = { gold = 80000, exp = 150000, items = { { itemId = 28033, count = 2 }, { itemId = 28057, count = 1 }, { itemId = 27645, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_mortis_the_sovereign_trio", name = "Mortis The Sovereign Triumvirate", objective = "Kill Mortis The Sovereign with 3 guild players nearby.", type = "boss_kill_with_guild", monster = "mortis the sovereign", target = 1, minGuildMembers = 3, rewards = { gold = 80000, exp = 150000, items = { { itemId = 28033, count = 2 }, { itemId = 28057, count = 1 }, { itemId = 27646, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_thalador_the_stormbringer_trio", name = "Thalador The Stormbringer Triumvirate", objective = "Kill Thalador The Stormbringer with 3 guild players nearby.", type = "boss_kill_with_guild", monster = "thalador the stormbringer", target = 1, minGuildMembers = 3, rewards = { gold = 80000, exp = 150000, items = { { itemId = 28033, count = 2 }, { itemId = 28057, count = 1 }, { itemId = 27647, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_tymagron_the_earthshaker_trio", name = "Tymagron The Earthshaker Triumvirate", objective = "Kill Tymagron The Earthshaker with 3 guild players nearby.", type = "boss_kill_with_guild", monster = "tymagron the earthshaker", target = 1, minGuildMembers = 3, rewards = { gold = 80000, exp = 150000, items = { { itemId = 28033, count = 2 }, { itemId = 28057, count = 1 }, { itemId = 27648, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_vorondor_the_eternal_flames_trio", name = "Vorondor The Eternal Flames Triumvirate", objective = "Kill Vorondor The Eternal Flames with 3 guild players nearby.", type = "boss_kill_with_guild", monster = "vorondor the eternal flames", target = 1, minGuildMembers = 3, rewards = { gold = 80000, exp = 150000, items = { { itemId = 28033, count = 2 }, { itemId = 28057, count = 1 }, { itemId = 27649, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_ashseer_dravok_trio", name = "Ashseer Dravok Triumvirate", objective = "Kill Ashseer Dravok with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "ashseer dravok", target = 1, minGuildMembers = 2, rewards = { gold = 80000, exp = 150000, items = { { itemId = 27673, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_emberlord_zanarth_trio", name = "Emberlord Zanarth Triumvirate", objective = "Kill Emberlord Zanarth with 2 guild players nearby and obtain a Guild Mount: Mycofoot Wanderer.", type = "boss_kill_with_guild", monster = "emberlord zanarth", target = 1, minGuildMembers = 2, guildMountId = 150, rewards = { gold = 115000, exp = 195000, items = { { itemId = 27680, count = 1 }, { itemId = 27676, count = 1 }, { itemId = 27691, count = 1 }, { itemId = 27692, count = 1 }, { itemId = 27693, count = 1 }, { itemId = 27695, count = 1 } }, mount = "Mycofoot Wanderer" } }
	definitions[#definitions + 1] = { id = "boss_hollowborn_zepharix_trio", name = "Hollowborn Zepharix Triumvirate", objective = "Kill Hollowborn Zepharix with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "hollowborn zepharix", target = 1, minGuildMembers = 2, rewards = { gold = 80000, exp = 150000, items = { { itemId = 27675, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_icebound_thryssan_trio", name = "Icebound Thryssan Triumvirate", objective = "Kill Icebound Thryssan with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "icebound thryssan", target = 1, minGuildMembers = 2, rewards = { gold = 80000, exp = 150000, items = { { itemId = 27677, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_tidebreaker_voryn_trio", name = "Tidebreaker Voryn Triumvirate", objective = "Kill Tidebreaker Voryn with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "tidebreaker voryn", target = 1, minGuildMembers = 2, rewards = { gold = 80000, exp = 150000, items = { { itemId = 27678, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_voidweaver_krythax_trio", name = "Voidweaver Krythax Triumvirate", objective = "Kill Voidweaver Krythax with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "voidweaver krythax", target = 1, minGuildMembers = 2, rewards = { gold = 80000, exp = 150000, items = { { itemId = 27679, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_fractalis_the_shardmaw_trio", name = "Fractalis The Shardmaw Triumvirate", objective = "Kill Fractalis The Shardmaw with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "fractalis the shardmaw", target = 1, minGuildMembers = 2, rewards = { gold = 80000, exp = 150000, items = { { itemId = 27674, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_vorgrun_of_the_jade_fangs_trio", name = "Vorgrun of the Jade Fangs Triumvirate", objective = "Kill Vorgrun of the Jade Fangs with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "vorgrun of the jade fangs", target = 1, minGuildMembers = 2, rewards = { gold = 30000, exp = 50000, items = { { itemId = 29855, count = 25 }, { itemId = 30003, count = 1 }} } }
	definitions[#definitions + 1] = { id = "boss_rhazgor_the_crimson_slayer_trio", name = "Rhazgor The Crimson Slayer Triumvirate", objective = "Kill Rhazgor The Crimson Slayer with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "rhazgor the crimson slayer", target = 1, minGuildMembers = 2, rewards = { gold = 35000, exp = 60000, items = { { itemId = 29856, count = 20 }, { itemId = 30014, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_nyxdrath_the_midnight_terror_trio", name = "Nyxdrath The Midnight Terror Triumvirate", objective = "Kill Nyxdrath The Midnight Terror with 3 guild players nearby and obtain a Guild Mount: Ironback Tusker and Guild Outfit: Void Seeker for male only.", type = "boss_kill_with_guild", monster = "nyxdrath the midnight terror", target = 1, minGuildMembers = 3, guildMountId = 147, guildOutfitMale = 1526, guildOutfitFemale = 0, guildOutfitAddons = 3, rewards = { gold = 150000, exp = 250000, items = { { itemId = 29858, count = 10}, { itemId = 29859, count = 2}, { itemId = 29920, count = 2 } }, mount = "Ironback Tusker" ,  outfit = "Void Seeker" } }
	definitions[#definitions + 1] = { id = "boss_morgrath_the_umbral_archmage_trio", name = "Morgrath the Umbral Archmage Triumvirate", objective = "Kill Morgrath the Umbral Archmage with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "morgrath the umbral archmage", target = 1, minGuildMembers = 2, rewards = { gold = 60000, exp = 105000, items = { { itemId = 29857, count = 20 }, { itemId = 29892, count = 10 }, { itemId = 29899, count = 10}, { itemId = 29898, count = 10 }, { itemId = 29897, count = 20} } } }
	definitions[#definitions + 1] = { id = "boss_frostreaver_the_glacialblade_trio", name = "Frostreaver The Glacialblade Triumvirate", objective = "Kill Frostreaver The Glacialblade with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "frostreaver the glacialblade", target = 1, minGuildMembers = 2, rewards = { gold = 45000, exp = 70000, items = { { itemId = 29856, count = 20 }, { itemId = 30016, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_goshnars_trio", name = "Goshnar's Megalomania", objective = "Kill 5 times Goshnar's Megalomania with 2 guild players nearby and obtain a Guild Mount: Crimson Scarab.", type = "boss_kill_with_guild", monster = "goshnar's megalomania", target = 5, minGuildMembers = 2, guildMountId = 148, rewards = { gold = 50000, exp = 105000, items = { { itemId = 27353, count = 2 } }, mount = "Crimson Scarab" } }
	definitions[#definitions + 1] = { id = "boss_vladrukh_trio", name = "Vladrukh Triumvirate", objective = "Kill 3 times Vladrukh with 2 guild players nearby and obtain Guild Outfit: Ember Nomad for Male only.", type = "boss_kill_with_guild", monster = "vladrukh", target = 3, minGuildMembers = 2, guildOutfitMale = 1525, guildOutfitFemale = 0, guildOutfitAddons = 3, rewards = { gold = 60000, exp = 105000, items = { { itemId = 30111, count = 1 },{ itemId = 30114, count = 1 } },  outfit = "Ember Nomad"  } }
	definitions[#definitions + 1] = { id = "boss_gravexon_the_devourer_trio", name = "Gravexon The Devourer Triumvirate", objective = "Kill Gravexon The Devourer with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "gravexon the devourer", target = 1, minGuildMembers = 2, rewards = { gold = 75000, exp = 125000, items = { { itemId = 30390, count = 2 }, { itemId = 28373, count = 1 }, { itemId = 28374, count = 1 }, { itemId = 28381, count = 1 }, { itemId = 30385, count = 1 }, { itemId = 30389, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_kaeldrath_the_fallen_trio", name = "Kaeldrath The Fallen Triumvirate", objective = "Kill Kaeldrath The Fallen with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "kaeldrath the fallen", target = 1, minGuildMembers = 2, rewards = { gold = 75000, exp = 125000, items = { { itemId = 30390, count = 2 }, { itemId = 28375 , count = 1 }, { itemId = 28376, count = 1 }, { itemId = 30382, count = 1 }, { itemId = 30386, count = 1 }, { itemId = 30390, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_velkorth_the_plaguebringer_trio", name = "Velkorth The Plaguebringer Triumvirate", objective = "Kill Velkorth The Plaguebringer with 2 guild players nearby.", type = "boss_kill_with_guild", monster = "velkorth the plaguebringer", target = 1, minGuildMembers = 2, rewards = { gold = 75000, exp = 125000, items = { { itemId = 2160, count = 10 }, { itemId = 28377, count = 1 }, { itemId = 28378, count = 1 }, { itemId = 30383, count = 1 }, { itemId = 30387, count = 1 }, { itemId = 30391, count = 1 } } } }
	definitions[#definitions + 1] = { id = "boss_zorgrath_the_carrion_trio", name = "Zorgrath The Carrion Triumvirate", objective = "Kill Zorgrath The Carrion with 2 guild players nearby and obtain Guild Outfit: Frostbound Reaper for Male only.", type = "boss_kill_with_guild", monster = "zorgrath the carrion", target = 1, minGuildMembers = 2, guildOutfitMale = 1524, guildOutfitFemale = 0, guildOutfitAddons = 3, rewards = { gold = 75000, exp = 125000, items = { { itemId = 2160, count = 10 }, { itemId = 28379, count = 1 }, { itemId = 28380, count = 1 }, { itemId = 30384, count = 1 }, { itemId = 30388, count = 1 }, { itemId = 30392, count = 1 }, { itemId = 30393, count = 1 } },  outfit = "Frostbound Reaper" } }
	definitions[#definitions + 1] = { id = "boss_velkyrion_the_fractured_trio", name = "Velkyrion The Fractured Triumvirate", objective = "Kill Velkyrion The Fractured with 2 guild players nearby and obtain a Guild Mount: Venomclaw Stalker", type = "boss_kill_with_guild", monster = "velkyrion the fractured", target = 1, minGuildMembers = 2, guildMountId = 149, rewards = { gold = 100000, exp = 200000, items = { { itemId = 28094, count = 1 }, { itemId = 28095, count = 3 } }, mount = "Venomclaw Stalker" } }
	definitions[#definitions + 1] = { id = "boss_kraxxis_the_corruptor_trio", name = "Kraxxis The Corruptor Triumvirate", objective = "Kill Kraxxis The Corruptor with 2 guild players nearby and obtain Guild Outfit: Sunflare Oracle.", type = "boss_kill_with_guild", monster = "kraxxis the corruptor", target = 1, minGuildMembers = 2, guildOutfitMale = 1523, guildOutfitFemale = 1522, guildOutfitAddons = 3, rewards = { gold = 150000, exp = 250000, items = { { itemId = 30619, count = 2 }, { itemId = 30618, count = 10 } }, outfit = "Sunflare Oracle" } }
	definitions[#definitions + 1] = { id = "boss_kraxxis_avatar_of_corruption_trio", name = "Kraxxis Avatar of Corruption Triumvirate", objective = "Kill Kraxxis Avatar of Corruption with 2 guild players nearby and obtain Guild Outfit: Celestial Seraph", type = "boss_kill_with_guild", monster = "kraxxis avatar of corruption", target = 1, minGuildMembers = 2, guildOutfitMale = 1527, guildOutfitFemale = 1528, guildOutfitAddons = 3, rewards = { gold = 200000, exp = 350000, items = { { itemId = 30619, count = 4 }, { itemId = 30618, count = 20 } }, outfit = "Celestial Seraph" } }
	definitions[#definitions + 1] = { id = "boss_rathmora_the_blood_tyrant_trio", name = "Rathmora The Blood Tyrant Triumvirate", objective = "Kill Rathmora The Blood Tyrant with 2 guild players nearby and obtain Guild Outfit: Sanctified Ravager", type = "boss_kill_with_guild", monster = "rathmora the blood tyrant", target = 1, minGuildMembers = 2, guildOutfitMale = 1529, guildOutfitFemale = 1530, guildOutfitAddons = 3, rewards = { gold = 150000, exp = 250000, items = { { itemId = 30631, count = 2 }, { itemId = 30630, count = 2 }, { itemId = 30625, count = 2 }, { itemId = 30621, count = 1 }, { itemId = 30615, count = 1 } }, outfit = "Sanctified Ravager" } }
	definitions[#definitions + 1] = { id = "boss_rathmora_ascendant_tyrant_trio", name = "Rathmora Ascendant Tyrant Triumvirate", objective = "Kill Rathmora Ascendant Tyrant with 2 guild players nearby and obtain Guild Outfit: Ivory Stalker", type = "boss_kill_with_guild", monster = "rathmora ascendant tyrant", target = 1, minGuildMembers = 2, guildOutfitMale = 1531, guildOutfitFemale = 1532, guildOutfitAddons = 3, rewards = { gold = 200000, exp = 350000, items = { { itemId = 30631, count = 3 }, { itemId = 30630, count = 3 }, { itemId = 30625, count = 4 }, { itemId = 30621, count = 2 }, { itemId = 30615, count = 2 } }, outfit = "Ivory Stalker" } }

	local definitionsById = {}
	for _, achievement in ipairs(definitions) do
		definitionsById[achievement.id] = achievement
	end

	local achievementApi = {}
	local getDynamicProgress

	local function ensureTables()
		db.query([[
			CREATE TABLE IF NOT EXISTS `guild_player_kill_totals` (
				`guild_id` int(11) NOT NULL,
				`total_kills` bigint(20) NOT NULL DEFAULT 0,
				`created_at` int(11) NOT NULL DEFAULT 0,
				`updated_at` int(11) NOT NULL DEFAULT 0,
				PRIMARY KEY (`guild_id`)
			) ENGINE=InnoDB DEFAULT CHARSET=utf8;
		]])
	end

	local function getGuildPlayerKillTotal(guildId)
		if not guildId or guildId <= 0 or not api.hasTable("guild_player_kill_totals") then
			return 0
		end

		local query = db.storeQuery("SELECT `total_kills` FROM `guild_player_kill_totals` WHERE `guild_id` = " .. guildId)
		if not query then
			return 0
		end

		local totalKills = result.getNumber(query, "total_kills")
		result.free(query)
		return tonumber(totalKills) or 0
	end

	local function incrementGuildPlayerKillTotal(guildId, amount)
		guildId = tonumber(guildId) or 0
		amount = math.max(1, math.floor(tonumber(amount) or 1))
		if guildId <= 0 or not api.hasTable("guild_player_kill_totals") then
			return false
		end

		local now = os.time()
		return db.query(
			"INSERT INTO `guild_player_kill_totals` (`guild_id`, `total_kills`, `created_at`, `updated_at`) VALUES (" ..
				guildId .. ", " .. amount .. ", " .. now .. ", " .. now .. ")" ..
			" ON DUPLICATE KEY UPDATE `total_kills` = `total_kills` + VALUES(`total_kills`), `updated_at` = VALUES(`updated_at`)"
		)
	end

	local function getProgressRows(guildId)
		local rows = {}
		if not guildId or guildId <= 0 or not api.hasTable("guild_achievement_progress") then
			return rows
		end

		local query = db.storeQuery(
			"SELECT `achievement_id`, `progress`, `completed_at`, `claimed_at` FROM `guild_achievement_progress` WHERE `guild_id` = " .. guildId
		)
		if not query then
			return rows
		end

		repeat
			rows[result.getString(query, "achievement_id")] = {
				progress = result.getNumber(query, "progress"),
				completedAt = result.getNumber(query, "completed_at"),
				claimedAt = result.getNumber(query, "claimed_at")
			}
		until not result.next(query)
		result.free(query)
		return rows
	end

	local function getCompletedCount(guildId)
		if not guildId or guildId <= 0 then
			return 0
		end

		local progressRows = getProgressRows(guildId)
		local count = 0
		for _, achievement in ipairs(definitions) do
			local row = progressRows[achievement.id] or {}
			local dynamicProgress = getDynamicProgress(guildId, achievement)
			local progress = math.min(tonumber(dynamicProgress ~= nil and dynamicProgress or row.progress) or 0, tonumber(achievement.target) or 0)
			if progress >= (tonumber(achievement.target) or 0) then
				count = count + 1
			end
		end
		return count
	end

	local function upsertProgress(guildId, achievementId, progress, completedAt, claimedAt)
		if not guildId or guildId <= 0 or not api.hasTable("guild_achievement_progress") then
			return false
		end

		local now = os.time()
		progress = math.max(0, tonumber(progress) or 0)
		completedAt = math.max(0, tonumber(completedAt) or 0)
		claimedAt = math.max(0, tonumber(claimedAt) or 0)

		return db.query(
			"INSERT INTO `guild_achievement_progress` (`guild_id`, `achievement_id`, `progress`, `completed_at`, `claimed_at`, `created_at`, `updated_at`) VALUES (" ..
				guildId .. ", " .. api.escape(achievementId) .. ", " .. progress .. ", " .. completedAt .. ", " .. claimedAt .. ", " .. now .. ", " .. now .. ")" ..
			" ON DUPLICATE KEY UPDATE `progress` = VALUES(`progress`), `completed_at` = VALUES(`completed_at`), `claimed_at` = VALUES(`claimed_at`), `updated_at` = VALUES(`updated_at`)"
		)
	end

	local function refreshForGuild(guildId)
		for _, member in ipairs(api.getOnlineGuildPlayers(guildId)) do
			achievementApi.send(member, 1, "")
		end
	end

	local function incrementProgress(guildId, achievementId, amount)
		if not guildId or guildId <= 0 or (tonumber(amount) or 0) <= 0 then
			return false
		end

		local definition = definitionsById[achievementId]
		if not definition then
			return false
		end

		local rows = getProgressRows(guildId)
		local row = rows[achievementId] or {}
		local current = tonumber(row.progress) or 0
		local targetCount = tonumber(definition.target) or 0
		if current >= targetCount then
			return false
		end

		local newProgress = math.min(targetCount, current + math.max(1, tonumber(amount) or 1))
		local completedAt = tonumber(row.completedAt) or 0
		if completedAt <= 0 and newProgress >= targetCount then
			completedAt = os.time()
		end

		return upsertProgress(guildId, achievementId, newProgress, completedAt, tonumber(row.claimedAt) or 0)
	end

	local function countNearbyGuildPlayers(guildId, position, radius)
		if not guildId or guildId <= 0 or type(position) ~= "table" then
			return 0
		end

		local count = 0
		for _, member in ipairs(api.getOnlineGuildPlayers(guildId)) do
			local memberPos = member:getPosition()
			if memberPos and memberPos.z == position.z and math.abs(memberPos.x - position.x) <= radius and math.abs(memberPos.y - position.y) <= radius then
				count = count + 1
			end
		end
		return count
	end

	local function getClaimedGuildCosmeticDefinitions(guildId)
		local entries = {}
		if not guildId or guildId <= 0 then
			return entries
		end

		local progressRows = getProgressRows(guildId)
		for _, achievement in ipairs(definitions) do
			local row = progressRows[achievement.id]
			if row and (tonumber(row.claimedAt) or 0) > 0 then
				local mountId = tonumber(achievement.guildMountId) or 0
				local outfitMale = tonumber(achievement.guildOutfitMale) or 0
				local outfitFemale = tonumber(achievement.guildOutfitFemale) or 0
				if mountId > 0 or outfitMale > 0 or outfitFemale > 0 then
					entries[#entries + 1] = achievement
				end
			end
		end

		return entries
	end

	local function applyGuildCosmeticAchievementToPlayer(player, achievement)
		if not player or not achievement then
			return
		end

		local mountId = tonumber(achievement.guildMountId) or 0
		if mountId > 0 then
			player:addMount(mountId)
		end

		local outfitAddons = math.max(0, tonumber(achievement.guildOutfitAddons) or 0)
		local outfitLooktypes = {
			tonumber(achievement.guildOutfitMale) or 0,
			tonumber(achievement.guildOutfitFemale) or 0
		}

		for _, lookType in ipairs(outfitLooktypes) do
			if lookType > 0 then
				player:addOutfit(lookType)
				if outfitAddons >= 1 then
					player:addOutfitAddon(lookType, 1)
				end
				if outfitAddons >= 2 then
					player:addOutfitAddon(lookType, 2)
				end
			end
		end
	end

	local function removeGuildCosmeticAchievementFromPlayer(player, achievement)
		if not player or not achievement then
			return
		end

		local mountId = tonumber(achievement.guildMountId) or 0
		if mountId > 0 then
			player:removeMount(mountId)
		end

		local outfitLooktypes = {
			tonumber(achievement.guildOutfitMale) or 0,
			tonumber(achievement.guildOutfitFemale) or 0
		}
		for _, lookType in ipairs(outfitLooktypes) do
			if lookType > 0 then
				player:removeOutfit(lookType)
			end
		end
	end

	local function syncGuildCosmeticsForPlayer(player, guildId)
		if not player then
			return
		end

		local claimedById = {}
		if guildId and guildId > 0 then
			for _, achievement in ipairs(getClaimedGuildCosmeticDefinitions(guildId)) do
				claimedById[achievement.id] = achievement
			end
		end

		for _, achievement in ipairs(definitions) do
			local hasCosmeticReward = (tonumber(achievement.guildMountId) or 0) > 0
				or (tonumber(achievement.guildOutfitMale) or 0) > 0
				or (tonumber(achievement.guildOutfitFemale) or 0) > 0
			if hasCosmeticReward then
				if claimedById[achievement.id] then
					applyGuildCosmeticAchievementToPlayer(player, achievement)
				else
					removeGuildCosmeticAchievementFromPlayer(player, achievement)
				end
			end
		end
	end

	getDynamicProgress = function(guildId, achievement)
		if not achievement or not api.getGuildRowById then
			return nil
		end
		if achievement.type == "guild_level_reached" then
			local guildRow = api.getGuildRowById(guildId)
			return guildRow and math.min(tonumber(guildRow.guild_level) or 0, tonumber(achievement.target) or 0) or 0
		end
		if achievement.type == "guild_member_count" then
			local memberCount = api.getGuildMemberCount and api.getGuildMemberCount(guildId) or 0
			return math.min(tonumber(memberCount) or 0, tonumber(achievement.target) or 0)
		end
		if achievement.type == "gold_contribution_total" then
			local guildRow = api.getGuildRowById(guildId)
			return guildRow and math.min(tonumber(guildRow.contribution) or 0, tonumber(achievement.target) or 0) or 0
		end
		if achievement.type == "premium_contribution_total" then
			local guildRow = api.getGuildRowById(guildId)
			return guildRow and math.min(tonumber(guildRow.premium_contribution) or 0, tonumber(achievement.target) or 0) or 0
		end
		if achievement.type == "guild_age_days" then
			local guildRow = api.getGuildRowById(guildId)
			local createdAt = guildRow and tonumber(guildRow.creationdata) or 0
			if createdAt <= 0 then
				return 0
			end
			local days = math.max(0, math.floor((os.time() - createdAt) / 86400))
			return math.min(days, tonumber(achievement.target) or 0)
		end
		if achievement.type == "global_player_kill_total" then
			return math.min(getGuildPlayerKillTotal(guildId), tonumber(achievement.target) or 0)
		end
		return nil
	end

	function achievementApi.awardPrismPlace(guildId)
		if not guildId or guildId <= 0 then
			return
		end

		for _, achievement in ipairs(definitions) do
			if achievement.type == "prism_place_total" then
				incrementProgress(guildId, achievement.id, 1)
			end
		end
	end

	function achievementApi.awardDynastiePlace(guildId)
		if not guildId or guildId <= 0 then
			return
		end

		for _, achievement in ipairs(definitions) do
			if achievement.type == "dynastie_place_total" then
				incrementProgress(guildId, achievement.id, 1)
			end
		end
	end

	function achievementApi.awardQuestClaim(guildId)
		if not guildId or guildId <= 0 then
			return
		end

		for _, achievement in ipairs(definitions) do
			if achievement.type == "quest_claim_total" then
				incrementProgress(guildId, achievement.id, 1)
			end
		end
	end

	function achievementApi.awardGlobalPlayerKill(guildId, amount)
		guildId = tonumber(guildId) or 0
		amount = math.max(1, math.floor(tonumber(amount) or 1))
		if guildId <= 0 then
			return
		end

		local completedAny = false
		if incrementGuildPlayerKillTotal(guildId, amount) then
			for _, achievement in ipairs(definitions) do
				if achievement.type == "global_player_kill_total" then
					local beforeRows = getProgressRows(guildId)
					local beforeRow = beforeRows[achievement.id] or {}
					local beforeProgress = tonumber(beforeRow.progress) or 0
					local targetCount = tonumber(achievement.target) or 0
					if beforeProgress < targetCount and incrementProgress(guildId, achievement.id, amount) then
						local afterProgress = math.min(targetCount, beforeProgress + amount)
						if afterProgress >= targetCount then
							completedAny = true
						end
					end
				end
			end
		end

		if completedAny then
			refreshForGuild(guildId)
		end
	end

	function achievementApi.awardMonsterKill(guildId, amount)
		guildId = tonumber(guildId) or 0
		amount = math.max(1, math.floor(tonumber(amount) or 1))
		if guildId <= 0 then
			return
		end

		for _, achievement in ipairs(definitions) do
			if achievement.type == "monster_kill_total" then
				incrementProgress(guildId, achievement.id, amount)
			end
		end
	end

	function achievementApi.awardPrismAttackPlayerKill(guildId, amount)
		if not guildId or guildId <= 0 then
			return
		end

		for _, achievement in ipairs(definitions) do
			if achievement.type == "prism_attack_kill_total" then
				incrementProgress(guildId, achievement.id, amount or 1)
			end
		end
	end

	function achievementApi.awardPrismDefensePlayerKill(guildId, amount)
		if not guildId or guildId <= 0 then
			return
		end

		for _, achievement in ipairs(definitions) do
			if achievement.type == "prism_defense_player_kill_total" then
				incrementProgress(guildId, achievement.id, amount or 1)
			end
		end
	end

	function achievementApi.awardPrismDestroyed(guildId, amount)
		if not guildId or guildId <= 0 then
			return
		end

		for _, achievement in ipairs(definitions) do
			if achievement.type == "prism_destroy_total" then
				incrementProgress(guildId, achievement.id, amount or 1)
			end
		end
	end

	function achievementApi.awardPrismCollectedGold(guildId, amount)
		guildId = tonumber(guildId) or 0
		amount = math.max(0, math.floor(tonumber(amount) or 0))
		if guildId <= 0 or amount <= 0 then
			return
		end

		for _, achievement in ipairs(definitions) do
			if achievement.type == "prism_collect_gold_total" then
				incrementProgress(guildId, achievement.id, amount)
			end
		end
	end

	function achievementApi.awardPrismCollectedExp(guildId, amount)
		guildId = tonumber(guildId) or 0
		amount = math.max(0, math.floor(tonumber(amount) or 0))
		if guildId <= 0 or amount <= 0 then
			return
		end

		for _, achievement in ipairs(definitions) do
			if achievement.type == "prism_collect_exp_total" then
				incrementProgress(guildId, achievement.id, amount)
			end
		end
	end

	function achievementApi.awardPrismCollectedRarity(guildId, rarityId)
		guildId = tonumber(guildId) or 0
		rarityId = math.max(0, math.floor(tonumber(rarityId) or 0))
		if guildId <= 0 or rarityId <= 0 then
			return
		end

		local rarityTypeById = {
			[1] = "prism_collect_rarity_common",
			[2] = "prism_collect_rarity_uncommon",
			[3] = "prism_collect_rarity_rare",
			[4] = "prism_collect_rarity_epic",
			[5] = "prism_collect_rarity_legendary",
			[6] = "prism_collect_rarity_exotic",
			[7] = "prism_collect_rarity_mythic",
			[8] = "prism_collect_rarity_chaos",
			[9] = "prism_collect_rarity_eternal",
			[10] = "prism_collect_rarity_divine",
			[11] = "prism_collect_rarity_phantasmal",
			[12] = "prism_collect_rarity_celestial",
			[13] = "prism_collect_rarity_cosmic",
			[14] = "prism_collect_rarity_abyssal",
			[15] = "prism_collect_rarity_transcendent"
		}
		local achievementType = rarityTypeById[rarityId]
		if not achievementType then
			return
		end

		for _, achievement in ipairs(definitions) do
			if achievement.type == achievementType then
				incrementProgress(guildId, achievement.id, 1)
			end
		end
	end

	function achievementApi.awardBossKill(player, target)
		if not player or not target or not target:isMonster() then
			return
		end

		local guild = player:getGuild()
		if not guild then
			return
		end

		local killedName = api.normalizeQuestMonsterName(target:getName())
		if killedName == "" then
			return
		end

		local touched = false
		local bossPos = target:getPosition()
		for _, achievement in ipairs(definitions) do
			if achievement.type == "boss_kill_with_guild" then
				for _, bossName in ipairs(api.normalizeQuestMonsterList(achievement.monster)) do
					if bossName == killedName then
						local nearbyCount = countNearbyGuildPlayers(guild:getId(), bossPos, 15)
						if nearbyCount >= (tonumber(achievement.minGuildMembers) or 1) and incrementProgress(guild:getId(), achievement.id, 1) then
							touched = true
						end
						break
					end
				end
			end
		end

	end

	function achievementApi.awardProfessionActivity(guildId, profession, amount)
		guildId = tonumber(guildId) or 0
		profession = tostring(profession or ""):lower()
		amount = math.max(1, math.floor(tonumber(amount) or 1))
		if guildId <= 0 or profession == "" then
			return
		end

		local achievementType = string.format("profession_%s_total", profession)
		for _, achievement in ipairs(definitions) do
			if achievement.type == achievementType then
				incrementProgress(guildId, achievement.id, amount)
			end
		end
	end

	local function buildData(guildId, page, search)
		page = math.max(1, math.floor(tonumber(page) or 1))
		search = tostring(search or ""):lower():trim()

		local progressRows = getProgressRows(guildId)
		local filtered = {}
		local completedCount = 0

		for _, achievement in ipairs(definitions) do
			local row = progressRows[achievement.id] or {}
			local dynamicProgress = getDynamicProgress(guildId, achievement)
			local progress = math.min(tonumber(dynamicProgress ~= nil and dynamicProgress or row.progress) or 0, tonumber(achievement.target) or 0)
			local completed = progress >= (tonumber(achievement.target) or 0)
			if completed then
				completedCount = completedCount + 1
			end

			local searchableText = (tostring(achievement.name or "") .. " " .. tostring(achievement.objective or "")):lower()
			if search == "" or searchableText:find(search, 1, true) then
				table.insert(filtered, {
					id = achievement.id,
					name = achievement.name,
					objective = achievement.objective,
					progress = progress,
					target = tonumber(achievement.target) or 0,
					completed = completed,
					claimed = (tonumber(row.claimedAt) or 0) > 0,
					rewardText = api.buildQuestRewardText(achievement.rewards),
					rewardEntries = api.buildQuestRewardEntries and api.buildQuestRewardEntries(achievement.rewards) or {}
				})
			end
		end

		table.sort(filtered, function(a, b)
			local function bucket(entry)
				if entry.completed and not entry.claimed then
					return 0
				end
				if not entry.completed then
					return 1
				end
				return 2
			end

			local bucketA = bucket(a)
			local bucketB = bucket(b)
			if bucketA ~= bucketB then
				return bucketA < bucketB
			end
			if bucketA == 1 then
				local ratioA = (tonumber(a.target) or 1) > 0 and ((tonumber(a.progress) or 0) / math.max(1, tonumber(a.target) or 1)) or 0
				local ratioB = (tonumber(b.target) or 1) > 0 and ((tonumber(b.progress) or 0) / math.max(1, tonumber(b.target) or 1)) or 0
				if ratioA ~= ratioB then
					return ratioA > ratioB
				end
			end
			return tostring(a.name or "") < tostring(b.name or "")
		end)

		local totalAll = #definitions
		local totalFiltered = #filtered
		local lastPage = math.max(1, math.ceil(totalFiltered / api.pageSize))
		if page > lastPage then
			page = lastPage
		end

		local offset = (page - 1) * api.pageSize
		local entries = {}
		for i = offset + 1, math.min(offset + api.pageSize, totalFiltered) do
			table.insert(entries, filtered[i])
		end

		return {
			page = page,
			lastPage = lastPage,
			pageSize = api.pageSize,
			total = totalAll,
			totalFiltered = totalFiltered,
			completed = completedCount,
			search = search,
			achievements = entries
		}
	end

	function achievementApi.send(player, page, search)
		local guildId = api.resolvePlayerGuildId and api.resolvePlayerGuildId(player) or (player:getGuild() and player:getGuild():getId() or 0)
		if not guildId or guildId <= 0 then
			return api.sendGuildPayload(player, "achievements", nil)
		end
		api.sendGuildPayload(player, "achievements", buildData(guildId, page, search))
	end

	function achievementApi.claimReward(player, data)
		local guild = player:getGuild()
		if not guild then
			return api.sendGuildError(player, "You are not in a guild.")
		end

		local achievementId = tostring(data and data.achievementId or "")
		if achievementId == "" then
			return api.sendGuildError(player, "Invalid achievement.")
		end

		local definition = definitionsById[achievementId]
		if not definition then
			return api.sendGuildError(player, "That achievement does not exist.")
		end

		local progressRows = getProgressRows(guild:getId())
		local row = progressRows[achievementId]
		local dynamicProgress = getDynamicProgress(guild:getId(), definition)
		if not row and dynamicProgress == nil then
			return api.sendGuildError(player, "This achievement has not been progressed yet.")
		end

		local targetCount = tonumber(definition.target) or 0
		local progress = tonumber(dynamicProgress ~= nil and dynamicProgress or row.progress) or 0
		if progress < targetCount then
			return api.sendGuildError(player, "This achievement is not completed yet.")
		end
		if (tonumber(row and row.claimedAt or 0) or 0) > 0 then
			return api.sendGuildError(player, "This achievement reward was already claimed.")
		end

		local guildRow = api.getGuildRowById(guild:getId())
		if not guildRow then
			return api.sendGuildError(player, "Could not load guild data.")
		end

		local rewards = definition.rewards or {}
		local rewardItems = {}
		if type(rewards.items) == "table" then
			for _, itemReward in ipairs(rewards.items) do
				local itemId = tonumber(itemReward.itemId) or 0
				local count = tonumber(itemReward.count) or 0
				if itemId > 0 and count > 0 then
					table.insert(rewardItems, { itemId = itemId, count = count, tooltip = "", attributes = "" })
				end
			end
		end

		if #rewardItems > 0 and api.canStoreItemsInGuildStorage and not api.canStoreItemsInGuildStorage(guild:getId(), rewardItems) then
			return api.sendGuildError(player, "There is no space in guild storage to claim this achievement reward.")
		end

		local storageSummary = api.tryStoreItemsInGuildStorage(guild:getId(), rewardItems)
		local rewardGold = tonumber(rewards.gold) or 0
		local rewardExp = tonumber(rewards.exp) or 0
		local newLevel = tonumber(guildRow.guild_level) or 1
		local newExp = tonumber(guildRow.guild_experience) or 0
		local leveledUp = false

		if rewardExp > 0 then
			local rawExp = newExp + rewardExp
			newLevel, newExp, _, leveledUp = api.calculateGuildLevelProgress(newLevel, rawExp)
		end

		local updates = {}
		if rewardGold > 0 and api.hasColumn("guilds", "balance") then
			table.insert(updates, "`balance` = " .. ((tonumber(guildRow.balance) or 0) + rewardGold))
		end
		if rewardExp > 0 and api.hasColumn("guilds", "guild_level") then
			table.insert(updates, "`guild_level` = " .. newLevel)
		end
		if rewardExp > 0 and api.hasColumn("guilds", "guild_experience") then
			table.insert(updates, "`guild_experience` = " .. newExp)
		end
		if #updates > 0 then
			db.query("UPDATE `guilds` SET " .. table.concat(updates, ", ") .. " WHERE `id` = " .. guild:getId())
		end

		upsertProgress(guild:getId(), achievementId, progress, tonumber(row and row.completedAt or 0) or os.time(), os.time())
		syncGuildCosmeticsForPlayer(player, guild:getId())
		for _, member in ipairs(api.getOnlineGuildPlayers(guild:getId())) do
			if member:getGuid() ~= player:getGuid() then
				syncGuildCosmeticsForPlayer(member, guild:getId())
			end
		end

		local rewardMessage = string.format(
			"[%s] %s claimed guild achievement rewards: {%s}.",
			definition.name,
			player:getName(),
			api.buildQuestRewardText(rewards)
		)
		api.addGuildMessages(api.getGuildInboxRecipients(guild:getId()), guild:getId(), api.messageTypes.QUEST_REWARD, rewardMessage, player:getGuid(), guild:getId())

		if (tonumber(storageSummary.overflowRows or 0) or 0) > 0 then
			api.addGuildMessages(
				api.getGuildInboxRecipients(guild:getId()),
				guild:getId(),
				api.messageTypes.QUEST_REWARD,
				string.format(
					"[%s] Storage overflow while claiming achievement rewards. {%d loot rows / %d items} could not be stored: %s.",
					definition.name,
					tonumber(storageSummary.overflowRows or 0) or 0,
					tonumber(storageSummary.overflowItems or 0) or 0,
					table.concat(storageSummary.overflowNames or {}, ", ")
				),
				player:getGuid(),
				guild:getId()
			)
		end

		achievementApi.send(player, 1, "")
		api.refreshGuildStorageForGuild(guild:getId())
		api.refreshGuildForMembers(guild:getId())
		if leveledUp then
			api.refreshGuildPerkState(guild:getId())
		end
	end

	function achievementApi.getDefinitionCount()
		return #definitions
	end

	function achievementApi.getCompletedCount(guildId)
		return getCompletedCount(guildId)
	end

	function achievementApi.getGuildPlayerKillTotal(guildId)
		return getGuildPlayerKillTotal(guildId)
	end

	function achievementApi.syncPlayerCosmetics(player)
		local guildId = api.resolvePlayerGuildId and api.resolvePlayerGuildId(player) or (player and player:getGuild() and player:getGuild():getId() or 0)
		syncGuildCosmeticsForPlayer(player, guildId)
	end

	function achievementApi.syncGuildCosmetics(guildId)
		if not guildId or guildId <= 0 then
			return
		end
		for _, member in ipairs(api.getOnlineGuildPlayers(guildId)) do
			syncGuildCosmeticsForPlayer(member, guildId)
		end
	end

	ensureTables()
	return achievementApi
end

return {
	create = create
}
