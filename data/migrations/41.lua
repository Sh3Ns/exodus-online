function onUpdateDatabase()
	print("> Updating database to version 41 (Znote Orders MountID)")
	db.query("ALTER TABLE `znote_shop_orders` ADD COLUMN `mountid` TINYINT NULL AFTER `itemid`;")
	return true
end