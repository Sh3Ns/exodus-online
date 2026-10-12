function onUpdateDatabase()
	print("> Updating database to version 42  ([Path of Exodus - PoE Module] passive skill tree)")
	db.query("ALTER TABLE `players` ADD COLUMN `passivetree` TEXT DEFAULT NULL;")
	return true
end