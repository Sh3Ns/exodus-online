function onUpdateDatabase()
	print("> Updating database to version 45 (market item attributes and currency)")
	db.query("ALTER TABLE `market_offers` ADD COLUMN `attributes` BLOB NULL AFTER `itemtype`")
	db.query("ALTER TABLE `market_offers` ADD COLUMN `currency` TINYINT UNSIGNED NOT NULL DEFAULT 0 AFTER `price`")
	db.query("ALTER TABLE `market_history` ADD COLUMN `currency` TINYINT UNSIGNED NOT NULL DEFAULT 0 AFTER `price`")
	return true
end
