function onUpdateDatabase()
	print("> Updating database to version 44 [Market Rarity Items]")

	db.query([[
		ALTER TABLE `market_offers`
		ADD COLUMN IF NOT EXISTS `attributes` BLOB NULL AFTER `itemtype`;
	]])

	return true
end