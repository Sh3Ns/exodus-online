local function columnExists(tableName, columnName)
	local resultId = db.storeQuery(string.format("SHOW COLUMNS FROM `%s` LIKE '%s'", tableName, columnName))
	if resultId then
		result.free(resultId)
		return true
	end
	return false
end

local function addColumnIfMissing(tableName, columnName, definition)
	if columnExists(tableName, columnName) then
		return true
	end

	if not db.query(string.format("ALTER TABLE `%s` ADD COLUMN `%s` %s;", tableName, columnName, definition)) then
		print(string.format("> Failed to add %s.%s.", tableName, columnName))
		return false
	end
	return true
end

function onUpdateDatabase()
	if not db.query([[
		CREATE TABLE IF NOT EXISTS `player_prey_resources` (
			`player_id` int NOT NULL,
			`unlocked_slots` tinyint unsigned NOT NULL DEFAULT 1,
			`hunting_task_unlocked_slots` tinyint unsigned NOT NULL DEFAULT 1,
			`wildcards` int unsigned NOT NULL DEFAULT 0,
			`hunting_task_tokens` int unsigned NOT NULL DEFAULT 0,
			`bounty_points` int unsigned NOT NULL DEFAULT 0,
			`soulseal_points` int unsigned NOT NULL DEFAULT 0,
			`updated_at` bigint unsigned NOT NULL DEFAULT 0,
			PRIMARY KEY (`player_id`),
			CONSTRAINT `player_prey_resources_player_fk`
				FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	]]) then
		print("> Failed to create player_prey_resources.")
		return false
	end

	if not addColumnIfMissing("player_prey_resources", "unlocked_slots", "tinyint unsigned NOT NULL DEFAULT 1 AFTER `player_id`") then
		return false
	end
	if not addColumnIfMissing("player_prey_resources", "hunting_task_unlocked_slots", "tinyint unsigned NOT NULL DEFAULT 1 AFTER `unlocked_slots`") then
		return false
	end
	if not addColumnIfMissing("player_prey_resources", "wildcards", "int unsigned NOT NULL DEFAULT 0 AFTER `hunting_task_unlocked_slots`") then
		return false
	end
	if not addColumnIfMissing("player_prey_resources", "hunting_task_tokens", "int unsigned NOT NULL DEFAULT 0 AFTER `wildcards`") then
		return false
	end
	if not addColumnIfMissing("player_prey_resources", "bounty_points", "int unsigned NOT NULL DEFAULT 0 AFTER `hunting_task_tokens`") then
		return false
	end
	if not addColumnIfMissing("player_prey_resources", "soulseal_points", "int unsigned NOT NULL DEFAULT 0 AFTER `bounty_points`") then
		return false
	end

	if not db.query([[
		CREATE TABLE IF NOT EXISTS `player_prey` (
			`player_id` int NOT NULL,
			`slot` tinyint unsigned NOT NULL,
			`monster_name` varchar(255) NOT NULL DEFAULT '',
			`look_type` smallint unsigned NOT NULL DEFAULT 0,
			`look_type_ex` smallint unsigned NOT NULL DEFAULT 0,
			`look_head` tinyint unsigned NOT NULL DEFAULT 0,
			`look_body` tinyint unsigned NOT NULL DEFAULT 0,
			`look_legs` tinyint unsigned NOT NULL DEFAULT 0,
			`look_feet` tinyint unsigned NOT NULL DEFAULT 0,
			`look_addons` tinyint unsigned NOT NULL DEFAULT 0,
			`look_mount` smallint unsigned NOT NULL DEFAULT 0,
			`look_wings` smallint unsigned NOT NULL DEFAULT 0,
			`look_aura` smallint unsigned NOT NULL DEFAULT 0,
			`look_shader` smallint unsigned NOT NULL DEFAULT 0,
			`bonus_type` tinyint unsigned NOT NULL DEFAULT 4,
			`bonus_value` smallint unsigned NOT NULL DEFAULT 0,
			`bonus_grade` tinyint unsigned NOT NULL DEFAULT 0,
			`expires_at` bigint unsigned NOT NULL DEFAULT 0,
			`free_reroll_at` bigint unsigned NOT NULL DEFAULT 0,
			`lock_type` tinyint unsigned NOT NULL DEFAULT 0,
			PRIMARY KEY (`player_id`, `slot`),
			CONSTRAINT `player_prey_player_fk`
				FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	]]) then
		print("> Failed to create player_prey.")
		return false
	end

	if not addColumnIfMissing("player_prey", "lock_type", "tinyint unsigned NOT NULL DEFAULT 0 AFTER `free_reroll_at`") then
		return false
	end

	if not db.query([[
		CREATE TABLE IF NOT EXISTS `player_hunting_tasks` (
			`player_id` int NOT NULL,
			`slot` tinyint unsigned NOT NULL,
			`monster_name` varchar(255) NOT NULL DEFAULT '',
			`current_kills` int unsigned NOT NULL DEFAULT 0,
			`required_kills` int unsigned NOT NULL DEFAULT 0,
			`reward_points` int unsigned NOT NULL DEFAULT 0,
			`updated_at` bigint unsigned NOT NULL DEFAULT 0,
			PRIMARY KEY (`player_id`, `slot`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	]]) then
		print("> Failed to create player_hunting_tasks.")
		return false
	end

	if not db.query([[
		CREATE TABLE IF NOT EXISTS `player_taskboard_shop_purchases` (
			`player_id` int NOT NULL,
			`offer_id` int NOT NULL,
			`amount` int unsigned NOT NULL DEFAULT 1,
			`updated_at` bigint unsigned NOT NULL DEFAULT 0,
			PRIMARY KEY (`player_id`, `offer_id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	]]) then
		print("> Failed to create player_taskboard_shop_purchases.")
		return false
	end

	if not db.query([[
		CREATE TABLE IF NOT EXISTS `player_taskboard_weekly` (
			`player_id` int NOT NULL,
			`difficulty` tinyint unsigned NOT NULL DEFAULT 0,
			`expires_at` bigint unsigned NOT NULL DEFAULT 0,
			`monsters` text NOT NULL,
			`items` text NOT NULL,
			`updated_at` bigint unsigned NOT NULL DEFAULT 0,
			PRIMARY KEY (`player_id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	]]) then
		print("> Failed to create player_taskboard_weekly.")
		return false
	end

	if not db.query([[
		CREATE TABLE IF NOT EXISTS `player_taskboard_weekly_unlocks` (
			`player_id` int NOT NULL,
			`kill_slots` tinyint unsigned NOT NULL DEFAULT 6,
			`delivery_slots` tinyint unsigned NOT NULL DEFAULT 6,
			`updated_at` bigint unsigned NOT NULL DEFAULT 0,
			PRIMARY KEY (`player_id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	]]) then
		print("> Failed to create player_taskboard_weekly_unlocks.")
		return false
	end

	if not db.query([[
		CREATE TABLE IF NOT EXISTS `player_taskboard_bounty` (
			`player_id` int NOT NULL,
			`difficulty` tinyint unsigned NOT NULL DEFAULT 3,
			`reroll_points` int unsigned NOT NULL DEFAULT 1,
			`claim_daily` tinyint unsigned NOT NULL DEFAULT 1,
			`unlocked_slots` tinyint unsigned NOT NULL DEFAULT 1,
			`monsters` text NOT NULL,
			`updated_at` bigint unsigned NOT NULL DEFAULT 0,
			PRIMARY KEY (`player_id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	]]) then
		print("> Failed to create player_taskboard_bounty.")
		return false
	end

	if not addColumnIfMissing("player_taskboard_bounty", "unlocked_slots", "tinyint unsigned NOT NULL DEFAULT 1 AFTER `claim_daily`") then
		return false
	end

	if not db.query([[
		CREATE TABLE IF NOT EXISTS `player_taskboard_bounty_preferences` (
			`player_id` int NOT NULL,
			`unlocked_slots` tinyint unsigned NOT NULL DEFAULT 1,
			`preferred` text NOT NULL,
			`unwanted` text NOT NULL,
			`updated_at` bigint unsigned NOT NULL DEFAULT 0,
			PRIMARY KEY (`player_id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	]]) then
		print("> Failed to create player_taskboard_bounty_preferences.")
		return false
	end

	if not db.query([[
		CREATE TABLE IF NOT EXISTS `player_taskboard_bounty_talisman` (
			`player_id` int NOT NULL,
			`stat1` tinyint unsigned NOT NULL DEFAULT 0,
			`stat2` tinyint unsigned NOT NULL DEFAULT 0,
			`stat3` tinyint unsigned NOT NULL DEFAULT 0,
			`stat4` tinyint unsigned NOT NULL DEFAULT 0,
			`updated_at` bigint unsigned NOT NULL DEFAULT 0,
			PRIMARY KEY (`player_id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	]]) then
		print("> Failed to create player_taskboard_bounty_talisman.")
		return false
	end

	return true
end
