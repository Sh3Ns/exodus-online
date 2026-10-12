function onUpdateDatabase()
	print("> Updating database to version 49 (64-bit market prices)")

	if not db.query("ALTER TABLE `market_offers` MODIFY COLUMN `price` BIGINT UNSIGNED NOT NULL DEFAULT 0") then
		print("> Failed to widen market_offers.price.")
		return false
	end

	if not db.query("ALTER TABLE `market_history` MODIFY COLUMN `price` BIGINT UNSIGNED NOT NULL DEFAULT 0") then
		print("> Failed to widen market_history.price.")
		return false
	end

	return true
end
