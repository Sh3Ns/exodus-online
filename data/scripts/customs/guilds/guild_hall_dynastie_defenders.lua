return {
	-- Level max of defender
	DEFENDER_LEVEL_CAP = 1000,
	-- Level cap, how many perks unlocks , 3 defenders of each one
	DEFENDER_PERK_LEVEL_CAP = 3,
	-- Chase radius of defenders from spawned on dynasty core
	DEFENDER_CHASE_RADIUS = 100,
	-- Increase Heal when upgrading ( per level )
	MONSTER_LEVEL_BONUS_HEALTH = 0.0100,
	-- Increase speed when upgrading ( per level )
	MONSTER_LEVEL_BONUS_SPEED = 0.0035,
	-- Increase damage when upgrading ( per level )
	MONSTER_LEVEL_BONUS_DAMAGE = 0.0011,
	-- Optional per-level upgrade requirements:
	-- upgradeCosts = {
	--   [1] = {
	--     gold = 50000,
	--     dynastieTokens = 50,
	--     items = {
	--       { itemId = 30654, itemName = "Dynasty Core Fragment", count = 50 }
	--     }
	--   },
	--   [2] = {
	--     gold = 100000,
	--     dynastieTokens = 100,
	--     items = {
	--       { itemId = 30654, itemName = "Dynasty Core Fragment", count = 100 }
	--     }
	--   }
	-- },

	defenders = {
		{
			id = "paladin",
			name = "Dynasty Paladin",
			monsterName = "Dynasty Paladin",
			lookType = 1515,
			lookHead = 114,
			lookBody = 94,
			lookLegs = 114,
			lookFeet = 114,
			lookAddons = 0,
			lookMount = 0,
			lookWings = 0,
			lookAura = 0,
			lookShader = 0,
			targetDistance = 3,
			maxHealth = 3500,
			baseSpeed = 450,
			defense = 28,
			armor = 26,
			damageMin = 140,
			damageMax = 320,
			attackSummary = "Holy arrows and ranged bolts",
			role = "Ranged Defender",
			upgradeDynastieTokens = 2,
			upgradeGold = 14500,
			upgradeCosts = {
				[100] = {
					gold = 150000,
					dynastieTokens = 50,
				},
				[200] = {
					gold = 225000,
					dynastieTokens = 75,
				},
				[300] = {
					gold = 325000,
					dynastieTokens = 100,
				},
				[400] = {
					gold = 450000,
					dynastieTokens = 125,
				},
				[500] = {
					gold = 500000,
					dynastieTokens = 150,
				},
				[600] = {
					gold = 650000,
					dynastieTokens = 175,
				},
				[700] = {
					gold = 700000,
					dynastieTokens = 200,
				},
				[800] = {
					gold = 800000,
					dynastieTokens = 225,
				},
				[900] = {
					gold = 900000,
					dynastieTokens = 250,
				},
				[1000] = {
					gold = 1000000,
					dynastieTokens = 300,
				},
			}
		},
		{
			id = "knight",
			name = "Dynasty Knight",
			monsterName = "Dynasty Knight",
			lookType = 1514,
			lookHead = 114,
			lookBody = 95,
			lookLegs = 114,
			lookFeet = 95,
			lookAddons = 0,
			lookMount = 0,
			lookWings = 0,
			lookAura = 0,
			lookShader = 0,
			targetDistance = 1,
			maxHealth = 4800,
			baseSpeed = 450,
			defense = 38,
			armor = 34,
			damageMin = 180,
			damageMax = 420,
			attackSummary = "Heavy melee and cleave strikes",
			role = "Frontline Defender",
			upgradeDynastieTokens = 2,
			upgradeGold = 12500,
			upgradeCosts = {
				[100] = {
					gold = 150000,
					dynastieTokens = 50,
				},
				[200] = {
					gold = 225000,
					dynastieTokens = 75,
				},
				[300] = {
					gold = 325000,
					dynastieTokens = 100,
				},
				[400] = {
					gold = 450000,
					dynastieTokens = 125,
				},
				[500] = {
					gold = 500000,
					dynastieTokens = 150,
				},
				[600] = {
					gold = 650000,
					dynastieTokens = 175,
				},
				[700] = {
					gold = 700000,
					dynastieTokens = 200,
				},
				[800] = {
					gold = 800000,
					dynastieTokens = 225,
				},
				[900] = {
					gold = 900000,
					dynastieTokens = 250,
				},
				[1000] = {
					gold = 1000000,
					dynastieTokens = 300,
				},
			}
		},
		{
			id = "mage",
			name = "Dynasty Mage",
			monsterName = "Dynasty Mage",
			lookType = 1516,
			lookHead = 114,
			lookBody = 114,
			lookLegs = 94,
			lookFeet = 95,
			lookAddons = 0,
			lookMount = 0,
			lookWings = 0,
			lookAura = 0,
			lookShader = 0,
			targetDistance = 2,
			maxHealth = 3000,
			baseSpeed = 450,
			defense = 20,
			armor = 18,
			damageMin = 170,
			damageMax = 300,
			attackSummary = "Energy, fire, and ice spells",
			role = "Arcane Defender",
			upgradeDynastieTokens = 2,
			upgradeGold = 14500,
			upgradeCosts = {
				[100] = {
					gold = 150000,
					dynastieTokens = 50,
				},
				[200] = {
					gold = 225000,
					dynastieTokens = 75,
				},
				[300] = {
					gold = 325000,
					dynastieTokens = 100,
				},
				[400] = {
					gold = 450000,
					dynastieTokens = 125,
				},
				[500] = {
					gold = 500000,
					dynastieTokens = 150,
				},
				[600] = {
					gold = 650000,
					dynastieTokens = 175,
				},
				[700] = {
					gold = 700000,
					dynastieTokens = 200,
				},
				[800] = {
					gold = 800000,
					dynastieTokens = 225,
				},
				[900] = {
					gold = 900000,
					dynastieTokens = 250,
				},
				[1000] = {
					gold = 1000000,
					dynastieTokens = 300,
				},
			}
		}
	},

	perks = {
		{
			id = "knight",
			name = "Unlock Defender Knight",
			icon = "knight_defender",
			lookType = 1514,
			role = "Frontline Defender",
			description = "Unlock and improve the number of knight defenders available to your dynasty.",
			upgradeDynastieTokens = 35,
			upgradeGold = 350000
		},
		{
			id = "paladin",
			name = "Unlock Paladin Defender",
			icon = "paladin_defender",
			lookType = 1515,
			role = "Ranged Defender",
			description = "Unlock and improve the number of paladin defenders available to your dynasty.",
			upgradeDynastieTokens = 35,
			upgradeGold = 350000
		},
		{
			id = "mage",
			name = "Unlock Mage Defender",
			icon = "mage_defender",
			lookType = 1516,
			role = "Arcane Defender",
			description = "Unlock and improve the number of mage defenders available to your dynasty.",
			upgradeDynastieTokens = 35,
			upgradeGold = 350000
		},
		{
			id = "element_physical",
			name = "Enhanced Physical Element",
			icon = "physical",
			lookType = 1514,
			role = "Elemental Bonus",
			description = "Increase physical damage by 1% per level while your guild owns an active dynastie core.",
			maxLevel = 5,
			upgradeDynastieTokens = 25,
			upgradeGold = 165000
		},
		{
			id = "element_fire",
			name = "Enhanced Fire Element",
			icon = "fire",
			lookType = 1516,
			role = "Elemental Bonus",
			description = "Increase fire element damage by 1% per level while your guild owns an active dynastie core.",
			maxLevel = 5,
			upgradeDynastieTokens = 25,
			upgradeGold = 165000
		},
		{
			id = "element_arcane",
			name = "Enhanced Arcane Element",
			icon = "arcane",
			lookType = 1516,
			role = "Elemental Bonus",
			description = "Increase arcane element damage by 1% per level while your guild owns an active dynastie core.",
			maxLevel = 5,
			upgradeDynastieTokens = 25,
			upgradeGold = 165000
		},
		{
			id = "element_ice",
			name = "Enhanced Ice Element",
			icon = "ice",
			lookType = 1516,
			role = "Elemental Bonus",
			description = "Increase ice element damage by 1% per level while your guild owns an active dynastie core.",
			maxLevel = 5,
			upgradeDynastieTokens = 25,
			upgradeGold = 165000
		},
		{
			id = "element_earth",
			name = "Enhanced Earth Element",
			icon = "earth",
			lookType = 1514,
			role = "Elemental Bonus",
			description = "Increase earth element damage by 1% per level while your guild owns an active dynastie core.",
			maxLevel = 5,
			upgradeDynastieTokens = 25,
			upgradeGold = 165000
		},
		{
			id = "element_water",
			name = "Enhanced Water Element",
			icon = "water",
			lookType = 1515,
			role = "Elemental Bonus",
			description = "Increase water element damage by 1% per level while your guild owns an active dynastie core.",
			maxLevel = 5,
			upgradeDynastieTokens = 25,
			upgradeGold = 165000
		},
		{
			id = "element_energy",
			name = "Enhanced Energy Element",
			icon = "energy",
			lookType = 1516,
			role = "Elemental Bonus",
			description = "Increase energy element damage by 1% per level while your guild owns an active dynastie core.",
			maxLevel = 5,
			upgradeDynastieTokens = 25,
			upgradeGold = 165000
		},
		{
			id = "element_holy",
			name = "Enhanced Holy Element",
			icon = "holy",
			lookType = 1515,
			role = "Elemental Bonus",
			description = "Increase holy element damage by 1% per level while your guild owns an active dynastie core.",
			maxLevel = 5,
			upgradeDynastieTokens = 25,
			upgradeGold = 165000
		},
		{
			id = "element_death",
			name = "Enhanced Death Element",
			icon = "death",
			lookType = 1514,
			role = "Elemental Bonus",
			description = "Increase death element damage by 1% per level while your guild owns an active dynastie core.",
			maxLevel = 5,
			upgradeDynastieTokens = 25,
			upgradeGold = 165000
		},
		{
			id = "element_healing",
			name = "Enhanced Combat Healing",
			icon = "healing",
			lookType = 1515,
			role = "Elemental Bonus",
			description = "Increase combat healing by 1% per level while your guild owns an active dynastie core.",
			maxLevel = 5,
			upgradeDynastieTokens = 25,
			upgradeGold = 165000
		},
		{
			id = "rarity_loot",
			name = "Increased Rarity Loot",
			icon = "rarity",
			lookType = 1515,
			role = "Loot Bonus",
			description = "Increase rarity loot chance by 1% per level while your guild owns an active dynastie core.",
			maxLevel = 10,
			upgradeDynastieTokens = 30,
			upgradeGold = 225000
		}
	}
}
