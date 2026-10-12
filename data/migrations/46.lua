function onUpdateDatabase()
	print("> Updating database to version 46 (guild management complete system)")

	db.query("ALTER TABLE `guilds` ADD COLUMN `emblem` varchar(64) NOT NULL DEFAULT '0'")
	db.query("ALTER TABLE `guilds` ADD COLUMN `language` tinyint unsigned NOT NULL DEFAULT 1")
	db.query("ALTER TABLE `guilds` ADD COLUMN `join_status` tinyint unsigned NOT NULL DEFAULT 1")
	db.query("ALTER TABLE `guilds` ADD COLUMN `required_level` int unsigned NOT NULL DEFAULT 0")
	db.query("ALTER TABLE `guilds` ADD COLUMN `guild_level` int unsigned NOT NULL DEFAULT 1")
	db.query("ALTER TABLE `guilds` ADD COLUMN `guild_experience` bigint unsigned NOT NULL DEFAULT 0")
	db.query("ALTER TABLE `guilds` ADD COLUMN `contribution` bigint unsigned NOT NULL DEFAULT 0")
	db.query("ALTER TABLE `guilds` ADD COLUMN `balance` bigint unsigned NOT NULL DEFAULT 0")
	db.query("ALTER TABLE `guilds` ADD COLUMN `perks` varchar(255) NOT NULL DEFAULT ''")
	db.query("ALTER TABLE `guilds` ADD COLUMN `premium_balance` bigint unsigned NOT NULL DEFAULT 0")
	db.query("ALTER TABLE `guilds` ADD COLUMN `premium_contribution` bigint unsigned NOT NULL DEFAULT 0")

	db.query("ALTER TABLE `guild_ranks` ADD COLUMN `permissions` int NOT NULL DEFAULT 0")

	db.query([[
		CREATE TABLE IF NOT EXISTS `guild_messages` (
			`id` int NOT NULL AUTO_INCREMENT,
			`player_id` int NOT NULL,
			`guild_id` int NOT NULL DEFAULT 0,
			`type` tinyint unsigned NOT NULL,
			`target_id` int NOT NULL DEFAULT 0,
			`source_guild_id` int NOT NULL DEFAULT 0,
			`text` varchar(255) NOT NULL,
			`created_at` bigint unsigned NOT NULL,
			`finished` tinyint unsigned NOT NULL DEFAULT 0,
			PRIMARY KEY (`id`),
			KEY `guild_messages_player_id` (`player_id`),
			KEY `guild_messages_guild_id` (`guild_id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	]])

	db.query([[
		CREATE TABLE IF NOT EXISTS `guild_contribution_history` (
			`id` int unsigned NOT NULL AUTO_INCREMENT,
			`guild_id` int NOT NULL,
			`player_id` int NOT NULL,
			`player_name` varchar(255) NOT NULL,
			`value` bigint unsigned NOT NULL DEFAULT 0,
			`currency` tinyint unsigned NOT NULL DEFAULT 1,
			`created_at` int unsigned NOT NULL DEFAULT 0,
			PRIMARY KEY (`id`),
			KEY `idx_gch_guild_player` (`guild_id`, `player_id`),
			KEY `idx_gch_guild_created` (`guild_id`, `created_at`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	]])

	db.query([[
		CREATE TABLE IF NOT EXISTS `guild_storage_items` (
			`guild_id` int NOT NULL,
			`slot` smallint unsigned NOT NULL,
			`item_id` int unsigned NOT NULL,
			`count` int unsigned NOT NULL DEFAULT 1,
			`attributes` blob NULL,
			`tooltip` text NULL,
			PRIMARY KEY (`guild_id`, `slot`),
			CONSTRAINT `guild_storage_items_ibfk_1`
				FOREIGN KEY (`guild_id`) REFERENCES `guilds` (`id`)
				ON DELETE CASCADE ON UPDATE CASCADE
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	]])

	db.query([[
		CREATE TABLE IF NOT EXISTS `guild_achievement_progress` (
			`guild_id` INT NOT NULL,
			`achievement_id` VARCHAR(64) NOT NULL,
			`progress` BIGINT NOT NULL DEFAULT 0,
			`completed_at` INT NOT NULL DEFAULT 0,
			`claimed_at` INT NOT NULL DEFAULT 0,
			`created_at` INT NOT NULL DEFAULT 0,
			`updated_at` INT NOT NULL DEFAULT 0,
			PRIMARY KEY (`guild_id`, `achievement_id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	]])

	if not db.query([[
		CREATE TABLE IF NOT EXISTS `guild_prisms` (
			`id` INT NOT NULL AUTO_INCREMENT,
			`guild_id` INT NOT NULL,
			`config_id` VARCHAR(64) NOT NULL,
			`owner_player_id` INT NOT NULL DEFAULT 0,
			`owner_player_name` VARCHAR(255) NOT NULL DEFAULT '',
			`placed_item_id` INT NOT NULL DEFAULT 0,
			`base_item_id` INT NOT NULL DEFAULT 0,
			`x` INT NOT NULL DEFAULT 0,
			`y` INT NOT NULL DEFAULT 0,
			`z` INT NOT NULL DEFAULT 0,
			`radius` INT NOT NULL DEFAULT 20,
			`gold_buffer` BIGINT NOT NULL DEFAULT 0,
			`exp_buffer` BIGINT NOT NULL DEFAULT 0,
			`loot_slots` INT NOT NULL DEFAULT 30,
			`expires_at` INT NOT NULL DEFAULT 0,
			`created_at` INT NOT NULL DEFAULT 0,
			`updated_at` INT NOT NULL DEFAULT 0,
			PRIMARY KEY (`id`),
			UNIQUE KEY `uq_guild_prisms_config` (`config_id`),
			KEY `idx_guild_prisms_guild` (`guild_id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	]]) then
		print("> Failed to create guild_prisms table.")
		return false
	end

	if not db.query([[
		CREATE TABLE IF NOT EXISTS `guild_prism_loot` (
			`id` INT NOT NULL AUTO_INCREMENT,
			`prism_id` INT NOT NULL,
			`slot` INT NOT NULL,
			`item_id` INT NOT NULL,
			`count` INT NOT NULL DEFAULT 1,
			PRIMARY KEY (`id`),
			UNIQUE KEY `uq_guild_prism_loot_slot` (`prism_id`, `slot`),
			KEY `idx_guild_prism_loot_prism` (`prism_id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	]]) then
		print("> Failed to create guild_prism_loot table.")
		return false
	end

	local resultId = db.storeQuery("SHOW COLUMNS FROM `guild_prisms` LIKE 'shield_until'")
	if not resultId then
		if not db.query("ALTER TABLE `guild_prisms` ADD COLUMN `shield_until` BIGINT NOT NULL DEFAULT 0 AFTER `expires_at`;") then
			print("> Failed to add guild_prisms.shield_until.")
			return false
		end
	else
		result.free(resultId)
	end

	resultId = db.storeQuery("SHOW COLUMNS FROM `guild_prisms` LIKE 'last_attack_at'")
	if not resultId then
		if not db.query("ALTER TABLE `guild_prisms` ADD COLUMN `last_attack_at` BIGINT NOT NULL DEFAULT 0 AFTER `shield_until`;") then
			print("> Failed to add guild_prisms.last_attack_at.")
			return false
		end
	else
		result.free(resultId)
	end

	resultId = db.storeQuery("SHOW COLUMNS FROM `guild_prism_loot` LIKE 'tooltip'")
	if not resultId then
		if not db.query([[
			ALTER TABLE `guild_prism_loot`
			ADD COLUMN `tooltip` TEXT NULL AFTER `count`;
		]]) then
			print("> Failed to add tooltip column to guild_prism_loot.")
			return false
		end
	else
		result.free(resultId)
	end

	resultId = db.storeQuery("SHOW COLUMNS FROM `guild_prism_loot` LIKE 'attributes'")
	if not resultId then
		if not db.query([[
			ALTER TABLE `guild_prism_loot`
			ADD COLUMN `attributes` BLOB NULL AFTER `tooltip`;
		]]) then
			print("> Failed to add attributes column to guild_prism_loot.")
			return false
		end
	else
		result.free(resultId)
	end

	if not db.query([[
		CREATE TABLE IF NOT EXISTS `guild_prism_cooldowns` (
			`guild_id` INT NOT NULL DEFAULT 0,
			`config_id` VARCHAR(64) NOT NULL,
			`cooldown_until` BIGINT NOT NULL DEFAULT 0,
			`updated_at` BIGINT NOT NULL DEFAULT 0,
			PRIMARY KEY (`guild_id`, `config_id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	]]) then
		print("> Failed to create guild_prism_cooldowns.")
		return false
	end

	if not db.query([[
		CREATE TABLE IF NOT EXISTS `guild_quest_progress` (
			`guild_id` INT NOT NULL,
			`cycle_type` VARCHAR(16) NOT NULL,
			`cycle_start` INT NOT NULL DEFAULT 0,
			`quest_id` VARCHAR(64) NOT NULL,
			`progress` INT NOT NULL DEFAULT 0,
			`completed_at` INT NOT NULL DEFAULT 0,
			`claimed_at` INT NOT NULL DEFAULT 0,
			`created_at` INT NOT NULL DEFAULT 0,
			`updated_at` INT NOT NULL DEFAULT 0,
			PRIMARY KEY (`guild_id`, `cycle_type`, `cycle_start`, `quest_id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	]]) then
		print("> Failed to create guild_quest_progress.")
		return false
	end

	db.query([[
		CREATE TABLE IF NOT EXISTS `guild_black_market_purchases` (
			`guild_id` INT NOT NULL,
			`offer_id` VARCHAR(64) NOT NULL,
			`cycle_start` INT NOT NULL DEFAULT 0,
			`purchased_at` INT NOT NULL DEFAULT 0,
			UNIQUE KEY `uq_guild_black_market_offer_cycle` (`guild_id`, `offer_id`, `cycle_start`),
			KEY `idx_guild_black_market_purchases_guild` (`guild_id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	]])

	db.query([[
		CREATE TABLE IF NOT EXISTS `guild_dynasties` (
			`id` INT NOT NULL AUTO_INCREMENT,
			`guild_id` INT NOT NULL,
			`config_id` VARCHAR(64) NOT NULL,
			`owner_player_id` INT NOT NULL DEFAULT 0,
			`owner_player_name` VARCHAR(255) NOT NULL DEFAULT '',
			`placed_item_id` INT NOT NULL DEFAULT 0,
			`base_item_id` INT NOT NULL DEFAULT 0,
			`x` INT NOT NULL DEFAULT 0,
			`y` INT NOT NULL DEFAULT 0,
			`z` INT NOT NULL DEFAULT 0,
			`radius` INT NOT NULL DEFAULT 0,
			`tax_rate` INT NOT NULL DEFAULT 1,
			`gold_buffer` BIGINT NOT NULL DEFAULT 0,
			`collect_available_at` INT NOT NULL DEFAULT 0,
			`placed_at` INT NOT NULL DEFAULT 0,
			`updated_at` INT NOT NULL DEFAULT 0,
			PRIMARY KEY (`id`),
			UNIQUE KEY `uq_guild_dynasties_config` (`config_id`),
			KEY `idx_guild_dynasties_guild` (`guild_id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	]])

	resultId = db.storeQuery("SHOW COLUMNS FROM `guilds` LIKE 'dynastie_tokens'")
	if not resultId then
		if not db.query("ALTER TABLE `guilds` ADD COLUMN `dynastie_tokens` BIGINT NOT NULL DEFAULT 0;") then
			print("> Failed to add guilds.dynastie_tokens.")
			return false
		end
	else
		result.free(resultId)
	end

	db.query([[
		CREATE TABLE IF NOT EXISTS `guild_dynastie_cooldowns` (
			`guild_id` INT NOT NULL,
			`config_id` VARCHAR(64) NOT NULL,
			`cooldown_until` INT NOT NULL DEFAULT 0,
			`updated_at` INT NOT NULL DEFAULT 0,
			UNIQUE KEY `uq_guild_dynastie_cooldown` (`guild_id`, `config_id`),
			KEY `idx_guild_dynastie_cooldown_guild` (`guild_id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	]])

	resultId = db.storeQuery("SHOW COLUMNS FROM `guild_dynasties` LIKE 'shield_until'")
	if not resultId then
		if not db.query("ALTER TABLE `guild_dynasties` ADD COLUMN `shield_until` BIGINT NOT NULL DEFAULT 0 AFTER `collect_available_at`;") then
			print("> Failed to add guild_dynasties.shield_until.")
			return false
		end
	else
		result.free(resultId)
	end

	if not db.query([[
		CREATE TABLE IF NOT EXISTS `guild_dynastie_attack_cooldowns` (
			`attacker_guild_id` INT NOT NULL,
			`config_id` VARCHAR(64) NOT NULL,
			`cooldown_until` BIGINT NOT NULL DEFAULT 0,
			`updated_at` BIGINT NOT NULL DEFAULT 0,
			PRIMARY KEY (`attacker_guild_id`, `config_id`),
			KEY `idx_guild_dynastie_attack_cooldown_guild` (`attacker_guild_id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	]]) then
		print("> Failed to create guild_dynastie_attack_cooldowns.")
		return false
	end

	resultId = db.storeQuery("SHOW COLUMNS FROM `guild_dynasties` LIKE 'level'")
	if not resultId then
		if not db.query("ALTER TABLE `guild_dynasties` ADD COLUMN `level` INT NOT NULL DEFAULT 1 AFTER `gold_buffer`;") then
			print("> Failed to add guild_dynasties.level.")
			return false
		end
	else
		result.free(resultId)
	end

	resultId = db.storeQuery("SHOW COLUMNS FROM `guild_dynasties` LIKE 'experience'")
	if not resultId then
		if not db.query("ALTER TABLE `guild_dynasties` ADD COLUMN `experience` BIGINT NOT NULL DEFAULT 0 AFTER `level`;") then
			print("> Failed to add guild_dynasties.experience.")
			return false
		end
	else
		result.free(resultId)
	end

	if not db.query([[
		CREATE TABLE IF NOT EXISTS `guild_dynastie_quest_progress` (
			`guild_id` INT NOT NULL,
			`config_id` VARCHAR(64) NOT NULL,
			`cycle_type` VARCHAR(16) NOT NULL,
			`cycle_start` BIGINT NOT NULL DEFAULT 0,
			`quest_id` VARCHAR(64) NOT NULL,
			`progress` BIGINT NOT NULL DEFAULT 0,
			`completed_at` BIGINT NOT NULL DEFAULT 0,
			`claimed_at` BIGINT NOT NULL DEFAULT 0,
			`created_at` BIGINT NOT NULL DEFAULT 0,
			`updated_at` BIGINT NOT NULL DEFAULT 0,
			PRIMARY KEY (`guild_id`, `config_id`, `cycle_type`, `cycle_start`, `quest_id`),
			KEY `idx_dynastie_quest_config` (`config_id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	]]) then
		print("> Failed to create guild_dynastie_quest_progress.")
		return false
	end

	resultId = db.storeQuery("SHOW COLUMNS FROM `guilds` LIKE 'dynastie_level'")
	if not resultId then
		if not db.query("ALTER TABLE `guilds` ADD COLUMN `dynastie_level` INT NOT NULL DEFAULT 1 AFTER `dynastie_tokens`;") then
			print("> Failed to add guilds.dynastie_level.")
			return false
		end
	else
		result.free(resultId)
	end

	resultId = db.storeQuery("SHOW COLUMNS FROM `guilds` LIKE 'dynastie_experience'")
	if not resultId then
		if not db.query("ALTER TABLE `guilds` ADD COLUMN `dynastie_experience` BIGINT NOT NULL DEFAULT 0 AFTER `dynastie_level`;") then
			print("> Failed to add guilds.dynastie_experience.")
			return false
		end
	else
		result.free(resultId)
	end

	if not db.query([[
		CREATE TABLE IF NOT EXISTS `guild_dynastie_defenders` (
			`guild_id` INT NOT NULL,
			`defender_id` VARCHAR(32) NOT NULL,
			`level` INT NOT NULL DEFAULT 0,
			`created_at` BIGINT NOT NULL DEFAULT 0,
			`updated_at` BIGINT NOT NULL DEFAULT 0,
			PRIMARY KEY (`guild_id`, `defender_id`),
			KEY `idx_guild_dynastie_defenders_guild` (`guild_id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	]]) then
		print("> Failed to create guild_dynastie_defenders.")
		return false
	end

	db.query([[
		CREATE TABLE IF NOT EXISTS `guild_dynastie_perks` (
			`guild_id` INT NOT NULL,
			`perk_id` VARCHAR(64) NOT NULL,
			`level` INT NOT NULL DEFAULT 0,
			`created_at` INT NOT NULL DEFAULT 0,
			`updated_at` INT NOT NULL DEFAULT 0,
			PRIMARY KEY (`guild_id`, `perk_id`),
			KEY `idx_guild_dynastie_perks_guild` (`guild_id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	]])

	db.query([[
		CREATE TABLE IF NOT EXISTS `guild_dynastie_passives` (
			`guild_id` INT NOT NULL,
			`defender_id` VARCHAR(64) NOT NULL,
			`node_id` VARCHAR(64) NOT NULL,
			`created_at` INT NOT NULL DEFAULT 0,
			`updated_at` INT NOT NULL DEFAULT 0,
			PRIMARY KEY (`guild_id`, `node_id`),
			KEY `idx_guild_dynastie_passives_guild` (`guild_id`),
			KEY `idx_guild_dynastie_passives_defender` (`guild_id`, `defender_id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	]])

	return true
end
