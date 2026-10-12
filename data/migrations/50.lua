function onUpdateDatabase()
	print("> Updating database to version 51 (Supply Stash)")

	if not db.query([[
		CREATE TABLE IF NOT EXISTS `player_stash` (
			`player_id` INT NOT NULL,
			`item_id` SMALLINT UNSIGNED NOT NULL,
			`amount` BIGINT UNSIGNED NOT NULL DEFAULT 0,
			PRIMARY KEY (`player_id`, `item_id`),
			CONSTRAINT `player_stash_player_fk`
				FOREIGN KEY (`player_id`) REFERENCES `players` (`id`)
				ON DELETE CASCADE
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	]]) then
		print("> Failed to create player_stash.")
		return false
	end

	return true
end
