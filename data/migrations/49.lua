local function columnExists(tableName, columnName)
  local resultId = db.storeQuery(string.format("SHOW COLUMNS FROM `%s` LIKE '%s'", tableName, columnName))
  if resultId then
    result.free(resultId)
    return true
  end
  return false
end

function onUpdateDatabase()
  print("> Updating database to version 50 (Wheel of Destiny + Weapon proficiency)")

  if not db.query([[
    CREATE TABLE IF NOT EXISTS `player_wheel_destiny` (
      `player_id` INT NOT NULL,
      `data` LONGTEXT NOT NULL,
      `presets` LONGTEXT NOT NULL,
      PRIMARY KEY (`player_id`),
      CONSTRAINT `player_wheel_destiny_player_fk`
        FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
  ]]) then
    print("> Failed to create player_wheel_destiny table.")
    return false
  end

  if not columnExists("player_wheel_destiny", "presets") then
    if not db.query("ALTER TABLE `player_wheel_destiny` ADD COLUMN `presets` LONGTEXT NULL AFTER `data`;") then
      print("> Failed to add player_wheel_destiny.presets column.")
      return false
    end
  end

  if not db.query("UPDATE `player_wheel_destiny` SET `presets` = '[]' WHERE `presets` IS NULL OR `presets` = '';") then
    print("> Failed to initialize player_wheel_destiny presets.")
    return false
  end

  if not db.query("ALTER TABLE `player_wheel_destiny` MODIFY COLUMN `presets` LONGTEXT NOT NULL;") then
    print("> Failed to require player_wheel_destiny presets.")
    return false
  end

  if not columnExists("players", "proficiency_data") then
    if not db.query("ALTER TABLE `players` ADD COLUMN `proficiency_data` TEXT NULL;") then
      print("> Failed to add players.proficiency_data.")
      return false
    end
  end

  return true
end
