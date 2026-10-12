-- Optional feature SQL for existing databases.
-- This file combines the small feature patches while leaving schema.sql and
-- SQL_ONLY_for_existing_server-DEPOT_BOX_READ_INSIDE.sql separate.

-- Battlepass
ALTER TABLE `players` ADD `battlepass` BLOB NULL
DEFAULT NULL AFTER `level`;

-- Passive tree
ALTER TABLE players
ADD COLUMN passivetree TEXT DEFAULT NULL;

-- Boosted boss
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

CREATE TABLE `boosted_boss` (
  `looktype` int(11) NOT NULL DEFAULT 0,
  `lookhead` int(11) NOT NULL DEFAULT 0,
  `lookbody` int(11) NOT NULL DEFAULT 0,
  `looklegs` int(11) NOT NULL DEFAULT 0,
  `lookfeet` int(11) NOT NULL DEFAULT 0,
  `lookaddons` int(11) NOT NULL DEFAULT 0,
  `date` varchar(250) NOT NULL DEFAULT '',
  `boostname` text DEFAULT NULL,
  `raceid` varchar(250) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `boosted_boss`
  ADD PRIMARY KEY (`date`);

COMMIT;

-- Boosted creature
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

CREATE TABLE `boosted_creature` (
  `looktype` int(11) NOT NULL DEFAULT 0,
  `lookhead` int(11) NOT NULL DEFAULT 0,
  `lookbody` int(11) NOT NULL DEFAULT 0,
  `looklegs` int(11) NOT NULL DEFAULT 0,
  `lookfeet` int(11) NOT NULL DEFAULT 0,
  `lookaddons` int(11) NOT NULL DEFAULT 0,
  `date` varchar(250) NOT NULL DEFAULT '',
  `boostname` text DEFAULT NULL,
  `raceid` varchar(250) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `boosted_creature`
  ADD PRIMARY KEY (`date`);

COMMIT;

-- Familiar
ALTER TABLE players ADD COLUMN pet_experience INT DEFAULT 0;
ALTER TABLE players ADD COLUMN pet_level INT DEFAULT 0;

-- Autoloot
ALTER TABLE `players` ADD `autoloot` BLOB NULL DEFAULT NULL AFTER `conditions`;

-- Character stats
ALTER TABLE players
  ADD COLUMN `stat_str` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  ADD COLUMN `stat_int` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  ADD COLUMN `stat_dex` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  ADD COLUMN `stat_vit` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  ADD COLUMN `stat_spr` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  ADD COLUMN `stat_wis` SMALLINT UNSIGNED NOT NULL DEFAULT 0;

-- Dungeons
CREATE TABLE IF NOT EXISTS `solo_runners` (
	`player_id` INT NOT NULL,
	`dungeon_id` SMALLINT NOT NULL,
	`difficulty` TINYINT NOT NULL,
	`time` MEDIUMINT UNSIGNED NOT NULL,
	FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE);

CREATE TABLE IF NOT EXISTS `group_runs` (
	`id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
	`dungeon_id` SMALLINT NOT NULL,
	`difficulty` TINYINT NOT NULL,
	`time` MEDIUMINT UNSIGNED NOT NULL,
	PRIMARY KEY (`id`));

CREATE TABLE IF NOT EXISTS `group_runners`(
	`run_id` INT UNSIGNED NOT NULL,
	`player` VARCHAR(255) NOT NULL,
	FOREIGN KEY (`run_id`) REFERENCES `group_runs` (`id`) ON DELETE CASCADE);
