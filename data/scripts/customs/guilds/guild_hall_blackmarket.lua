local function create(api)
	local offersPool = {
		{ id = "exalted_core", name = "Exalted Core", itemId = 28345, count = 10, duration = 1 * 60 * 60, gold = 80000, premium = 0, chance = 40 },
		{ id = "dynasty_core", name = "Dynasty Core", itemId = 30654, count = 1, duration = 1 * 60 * 60, gold = 125000, premium = 0, chance = 35 },
		{ id = "dynasty_core_premium", name = "Dynasty Core", itemId = 30654, count = 1, duration = 2 * 60 * 60, gold = 0, premium = 10, chance = 45 },
		{ id = "exalted_core_premium", name = "Exalted Core", itemId = 28345, count = 25, duration = 2 * 60 * 60, gold = 0, premium = 10, chance = 55 },
		{ id = "prism_core", name = "Prism Core", itemId = 30657, count = 2, duration = 1 * 60 * 60, gold = 130000, premium = 0, chance = 55 },
		{ id = "prism_core_premium", name = "Prism Core", itemId = 30657, count = 4, duration = 2 * 60 * 60, gold = 0, premium = 15, chance = 65 },
		{ id = "mythic_health_potion", name = "Mythic Health Pack", itemId = 28079, count = 150, duration = 2 * 60 * 60, gold = 145000, premium = 0, chance = 55 },
		{ id = "mythic_mana_potion", name = "Mythic Mana Pack", itemId = 28083, count = 150, duration = 2 * 60 * 60, gold = 145000, premium = 0, chance = 55 },
		{ id = "mythic_spirit_potion", name = "Mythic Spirit Pack", itemId = 28091, count = 150, duration = 2 * 60 * 60, gold = 145000, premium = 0, chance = 55 },
		{ id = "double_potion", name = "Double Exp Potion", itemId = 28095, count = 1, duration = 1 * 60 * 60, gold = 65000, premium = 0, chance = 30 },
		{ id = "rare_essence", name = "Rare Essence", itemId = 27703, count = 3, duration = 2 * 60 * 60, gold = 50000, premium = 0, chance = 60 },
		{ id = "epic_essence", name = "Epic Essence", itemId = 27704, count = 3, duration = 1 * 60 * 60, gold = 70000, premium = 0, chance = 50 },
		{ id = "mythic_essence", name = "Mythic Essence", itemId = 27705, count = 3, duration = 1 * 60 * 60, gold = 95000, premium = 0, chance = 40 },
		{ id = "ticket_roulette", name = "Ticket Roulette", itemId = 28057, count = 1, duration = 1 * 60 * 60, gold = 180000, premium = 0, chance = 25 },
		{ id = "ticket_roulette_premium", name = "Ticket Roulette", itemId = 28057, count = 1, duration = 1 * 60 * 60, gold = 0, premium = 12, chance = 55 },
		{ id = "boss_token", name = "Boss Token", itemId = 28033, count = 1, duration = 1 * 60 * 60, gold = 300000, premium = 0, chance = 15 },
		{ id = "boss_token_premium", name = "Boss Token", itemId = 28033, count = 1, duration = 2 * 60 * 60, gold = 0, premium = 20, chance = 32 },
		{ id = "sliver", name = "Sliver", itemId = 28344, count = 40, duration = 1 * 60 * 60, gold = 40000, premium = 0, chance = 45 },
		{ id = "dusts", name = "Dust's", itemId = 28343, count = 100, duration = 1 * 60 * 60, gold = 50000, premium = 0, chance = 45 },
		{ id = "sliver_premium", name = "Sliver", itemId = 28344, count = 40, duration = 1 * 60 * 60, gold = 0, premium = 15, chance = 65 },
		{ id = "dusts_premium", name = "Dust's", itemId = 28343, count = 100, duration = 1 * 60 * 60, gold = 0, premium = 20, chance = 40 },
		{ id = "common_three_star", name = "Common Three Stars Inlay Stone", itemId = 27136, count = 5, duration = 1 * 60 * 60, gold = 28500, premium = 0, chance = 45 },
		{ id = "rare_three_star", name = "Rare Three Stars Inlay Stone", itemId = 27139, count = 5, duration = 1 * 60 * 60, gold = 37500, premium = 0, chance = 40 },
		{ id = "very_rare_three_star", name = "Very Rare Three Stars Inlay Stone", itemId = 27142, count = 5, duration = 1 * 60 * 60, gold = 47500, premium = 0, chance = 35 },
		{ id = "epic_three_star", name = "Epic Three Stars Inlay Stone", itemId = 27145, count = 5, duration = 1 * 60 * 60, gold = 67500, premium = 0, chance = 30 },
		{ id = "legendary_three_star", name = "Legendary Three Stars Inlay Stone", itemId = 27148, count = 5, duration = 1 * 60 * 60, gold = 87500, premium = 0, chance = 25 },
		{ id = "upgrade_rune_1", name = "Upgrade rune v1", itemId = 29619, count = 5, duration = 1 * 60 * 60, gold = 50000, premium = 0, chance = 40 },
		{ id = "upgrade_rune_2", name = "Upgrade rune v2", itemId = 29620, count = 5, duration = 1 * 60 * 60, gold = 90000, premium = 0, chance = 30 },
		{ id = "upgrade_rune_3", name = "Upgrade rune v3", itemId = 29621, count = 5, duration = 1 * 60 * 60, gold = 125000, premium = 0, chance = 20 },
		{ id = "upgrade_rune_4", name = "Upgrade rune v4", itemId = 29622, count = 5, duration = 1 * 60 * 60, gold = 180000, premium = 0, chance = 10 },
		{ id = "waystone_tier_III", name = "Waystone Tier III", itemId = 29847, count = 1, duration = 2 * 60 * 60, gold = 50000, premium = 0, chance = 30 },
		{ id = "waystone_tier_VI", name = "Waystone Tier VI", itemId = 29848, count = 1, duration = 2 * 60 * 60, gold = 65000, premium = 0, chance = 25 },
		{ id = "waystone_tier_V", name = "Waystone Tier V", itemId = 29849, count = 1, duration = 2 * 60 * 60, gold = 80000, premium = 0, chance = 20 },
		{ id = "waystone_tier_VI", name = "Waystone Tier VI", itemId = 29850, count = 1, duration = 2 * 60 * 60, gold = 95000, premium = 0, chance = 15 },
		{ id = "exalted_orb", name = "Exalted Orb", itemId = 29855, count = 10, duration = 2 * 60 * 60, gold = 65000, premium = 0, chance = 55 },
		{ id = "chaos_orb", name = "Chaos Orb", itemId = 29856, count = 10, duration = 2 * 60 * 60, gold = 105000, premium = 0, chance = 35 },
		{ id = "divine_orb", name = "Divine Orb", itemId = 29857, count = 10, duration = 1 * 60 * 60, gold = 195000, premium = 0, chance = 15 },
		{ id = "seal_infernal_protection", name = "Seal Infernal Protection", itemId = 30395, count = 1, duration = 1 * 60 * 60, gold = 195000, premium = 0, chance = 15 },
		{ id = "seal_fractured_protection", name = "Seal Fractured Protection", itemId = 30396, count = 1, duration = 1 * 60 * 60, gold = 250000, premium = 0, chance = 15 },
		{ id = "stamina_extension", name = "Stamina Extension", itemId = 27990, count = 1, duration = 1 * 60 * 60, gold = 145000, premium = 0, chance = 15 },
		{ id = "stamina_extension_premium", name = "Stamina Extension", itemId = 27990, count = 1, duration = 2 * 60 * 60, gold = 0, premium = 25, chance = 25 },
	}

	local marketApi = {}
	local cycleSeconds = 24 * 60 * 60
	local offersPerDay = math.max(1, tonumber(api.dailyCount) or 10)

	local function cycleStart(now)
		now = tonumber(now) or os.time()
		return now - (now % cycleSeconds)
	end

	local function hasPurchaseTable()
		return not api.hasTable or api.hasTable("guild_black_market_purchases")
	end

	local function hasGuildPurchasedOffer(guildId, offerInstanceId)
		if not hasPurchaseTable() then
			return false
		end

		local resultId = db.storeQuery(
			"SELECT `guild_id` FROM `guild_black_market_purchases` WHERE `guild_id` = " .. tonumber(guildId) ..
			" AND `offer_id` = " .. db.escapeString(tostring(offerInstanceId)) .. " LIMIT 1"
		)
		if not resultId then
			return false
		end

		result.free(resultId)
		return true
	end

	local function registerGuildPurchase(guildId, offerInstanceId, dailyCycleStart)
		if not hasPurchaseTable() then
			return true
		end

		return db.query(
			"INSERT INTO `guild_black_market_purchases` (`guild_id`, `offer_id`, `cycle_start`, `purchased_at`) VALUES (" ..
			tonumber(guildId) .. ", " .. db.escapeString(tostring(offerInstanceId)) .. ", " .. tonumber(dailyCycleStart) .. ", " .. os.time() .. ")"
		)
	end

	local function getWeightedOffer(seed)
		local totalWeight = 0
		for _, offer in ipairs(offersPool) do
			totalWeight = totalWeight + math.max(1, tonumber(offer.chance or offer.weight) or 1)
		end
		if totalWeight <= 0 then
			return offersPool[1]
		end

		local ticket = (tonumber(seed) or 0) % totalWeight
		for _, offer in ipairs(offersPool) do
			ticket = ticket - math.max(1, tonumber(offer.chance or offer.weight) or 1)
			if ticket < 0 then
				return offer
			end
		end

		return offersPool[#offersPool]
	end

	local function buildOfferData(offer, instanceStart, slotIndex)
		local itemType = ItemType(tonumber(offer.itemId) or 0)
		local clientId = itemType and itemType:getClientId() or 0
		local itemName = (itemType and itemType:getName()) or offer.name or ("Item #" .. tostring(offer.itemId))
		local duration = math.max(60, tonumber(offer.duration) or 3600)
		local expiresAt = instanceStart + duration
		return {
			id = offer.id,
			instanceId = string.format("%s:%d:%d", tostring(offer.id), tonumber(slotIndex) or 0, tonumber(instanceStart) or 0),
			name = offer.name or itemName,
			itemId = tonumber(offer.itemId) or 0,
			clientId = clientId,
			count = math.max(1, tonumber(offer.count) or 1),
			gold = math.max(0, tonumber(offer.gold) or 0),
			premium = math.max(0, tonumber(offer.premium) or 0),
			expiresAt = expiresAt,
			duration = duration,
			durationLabel = duration,
			cycleStart = instanceStart,
			slot = slotIndex
		}
	end

	local function buildSlotOffer(slotIndex, now)
		now = tonumber(now) or os.time()
		local dayStart = cycleStart(now)
		if #offersPool == 0 then
			return nil
		end

		local instanceStart = dayStart
		local safety = 0

		while safety < 256 do
			local offerSeed = math.floor(instanceStart / 60) + (tonumber(slotIndex) or 0) * 9973 + safety * 137
			local offer = getWeightedOffer(offerSeed)
			local duration = math.max(60, tonumber(offer.duration) or 3600)
			if now < instanceStart + duration then
				return buildOfferData(offer, instanceStart, slotIndex)
			end

			instanceStart = instanceStart + duration
			safety = safety + 1
		end

		return buildOfferData(getWeightedOffer(dayStart + slotIndex), dayStart, slotIndex)
	end

	local function getDailyOffers(now)
		now = tonumber(now) or os.time()
		local result = {}
		local nextRefreshAt = now + cycleSeconds

		for slotIndex = 1, offersPerDay do
			local offer = buildSlotOffer(slotIndex, now)
			if offer then
				table.insert(result, offer)
				if tonumber(offer.expiresAt) and offer.expiresAt < nextRefreshAt then
					nextRefreshAt = offer.expiresAt
				end
			end
		end

		return result, nextRefreshAt
	end

	local function findOfferById(offerId, offerInstanceId, now)
		local offers = getDailyOffers(now)
		for _, offer in ipairs(offers) do
			if offerInstanceId and offerInstanceId ~= "" then
				if offer.instanceId == offerInstanceId then
					return offer
				end
			elseif offer.id == offerId then
				return offer
			end
		end
		return nil
	end

	local function canStoreItems(guildId, items)
		local rows = api.getGuildStorageRows(guildId)
		local capacity = api.getGuildStorageCapacity(guildId)
		local simulated = {}

		for slot, row in pairs(rows) do
			simulated[slot] = {
				itemId = row.itemId,
				count = tonumber(row.count) or 0,
				tooltip = tostring(row.tooltip or ""),
				attributes = tostring(row.attributes or "")
			}
		end

		for _, item in ipairs(items) do
			local itemId = tonumber(item.itemId) or 0
			local count = math.max(0, tonumber(item.count) or 0)
			local tooltip = tostring(item.tooltip or "")
			local attributes = tostring(item.attributes or "")
			local itemType = ItemType(itemId)
			local chunks = api.splitItemCountForStorage(itemId, count, tooltip, attributes)

			for _, chunk in ipairs(chunks) do
				local chunkCount = tonumber(chunk.count) or 0
				local placed = false

				if itemType and itemType:isStackable() then
					for slot = 1, capacity do
						local row = simulated[slot]
						if row and row.itemId == itemId and row.tooltip == tooltip and row.attributes == attributes and row.count < api.stackLimit then
							local spaceLeft = api.stackLimit - row.count
							if spaceLeft >= chunkCount then
								row.count = row.count + chunkCount
								placed = true
								break
							end
						end
					end
				end

				if not placed then
					for slot = 1, capacity do
						if not simulated[slot] then
							simulated[slot] = {
								itemId = itemId,
								count = chunkCount,
								tooltip = tooltip,
								attributes = attributes
							}
							placed = true
							break
						end
					end
				end

				if not placed then
					return false
				end
			end
		end

		return true
	end

	local function buildData(guildId, now)
		now = tonumber(now) or os.time()
		local offers, refreshAt = getDailyOffers(now)
		local entries = {}
		local guildRow = guildId and api.getGuildRowById(guildId) or nil
		local guildGold = tonumber(guildRow and guildRow.balance) or 0
		local guildPremium = tonumber(guildRow and guildRow.premium_balance) or 0

		for _, offer in ipairs(offers) do
			local itemType = ItemType(tonumber(offer.itemId) or 0)
			local purchased = hasGuildPurchasedOffer(guildId, offer.instanceId)
			table.insert(entries, {
				id = offer.id,
				instanceId = offer.instanceId,
				name = offer.name,
				itemId = offer.itemId,
				clientId = offer.clientId,
				count = offer.count,
				gold = offer.gold,
				premium = offer.premium,
				expiresAt = offer.expiresAt,
				duration = offer.duration,
				durationLabel = offer.durationLabel,
				expired = now >= offer.expiresAt,
				priceText = offer.gold > 0 and (tostring(offer.gold) .. " gold") or (tostring(offer.premium) .. " premium points"),
				description = string.format("%dx %s", offer.count, (itemType and itemType:getName()) or offer.name),
				affordable = (offer.gold > 0 and guildGold >= offer.gold) or (offer.premium > 0 and guildPremium >= offer.premium),
				purchased = purchased
			})
		end

		return {
			refreshAt = refreshAt,
			offers = entries
		}
	end

	function marketApi.send(player)
		local guildId = api.resolvePlayerGuildId and api.resolvePlayerGuildId(player) or (player:getGuild() and player:getGuild():getId() or 0)
		if not guildId or guildId <= 0 then
			return api.sendGuildPayload(player, "blackMarket", nil)
		end
		api.sendGuildPayload(player, "blackMarket", buildData(guildId, os.time()))
	end

	function marketApi.purchase(player, data)
		local guild = player:getGuild()
		if not guild then
			return api.sendGuildError(player, "You are not in a guild.")
		end

		local offerId = tostring(data and data.offerId or "")
		local offerInstanceId = tostring(data and data.offerInstanceId or "")
		if offerId == "" then
			return api.sendGuildError(player, "Invalid black market offer.")
		end

		local now = os.time()
		local offer = findOfferById(offerId, offerInstanceId, now)
		if not offer then
			return api.sendGuildError(player, "This black market offer is not available.")
		end
		if now >= offer.expiresAt then
			return api.sendGuildError(player, "This black market offer has expired.")
		end
		if hasGuildPurchasedOffer(guild:getId(), offer.instanceId) then
			return api.sendGuildError(player, "Your guild already purchased this offer today.")
		end

		local guildRow = api.getGuildRowById(guild:getId())
		if not guildRow then
			return api.sendGuildError(player, "Could not load guild data.")
		end

		if offer.premium > 0 and not api.hasColumn("guilds", "premium_balance") then
			return api.sendGuildError(player, "Guild premium balance is not available.")
		end

		local guildGold = tonumber(guildRow.balance) or 0
		local guildPremium = tonumber(guildRow.premium_balance) or 0
		if offer.gold > 0 and guildGold < offer.gold then
			return api.sendGuildError(player, "Your guild does not have enough gold.")
		end
		if offer.premium > 0 and guildPremium < offer.premium then
			return api.sendGuildError(player, "Your guild does not have enough premium points.")
		end

		local itemType = ItemType(offer.itemId)
		local rewardItems = {
			{
				itemId = offer.itemId,
				count = offer.count,
				tooltip = (itemType and itemType:getName()) or offer.name,
				attributes = ""
			}
		}

		if not canStoreItems(guild:getId(), rewardItems) then
			return api.sendGuildError(player, "Guild storage does not have enough space for this purchase.")
		end

		local updates = {}
		if offer.gold > 0 and api.hasColumn("guilds", "balance") then
			table.insert(updates, "`balance` = " .. (guildGold - offer.gold))
		end
		if offer.premium > 0 and api.hasColumn("guilds", "premium_balance") then
			table.insert(updates, "`premium_balance` = " .. (guildPremium - offer.premium))
		end
		if #updates > 0 then
			db.query("UPDATE `guilds` SET " .. table.concat(updates, ", ") .. " WHERE `id` = " .. guild:getId())
		end

		local storageSummary = api.tryStoreItemsInGuildStorage(guild:getId(), rewardItems)
		if (tonumber(storageSummary.overflowRows) or 0) > 0 then
			return api.sendGuildError(player, "Guild storage could not receive this item.")
		end
		if not registerGuildPurchase(guild:getId(), offer.instanceId, offer.cycleStart) then
			return api.sendGuildError(player, "Could not register this black market purchase.")
		end

		api.refreshGuildStorageForGuild(guild:getId())
		api.refreshGuildForMembers(guild:getId())
		api.addGuildMessages(
			api.getGuildInboxRecipients(guild:getId()),
			guild:getId(),
			api.messageTypes.BLACK_MARKET_PURCHASE,
			string.format("[%s] %s purchased {%dx %s} from the Black Market for %s.", offer.name, player:getName(), offer.count, (itemType and itemType:getName()) or offer.name, offer.gold > 0 and (tostring(offer.gold) .. " gold") or (tostring(offer.premium) .. " premium points")),
			player:getGuid(),
			guild:getId()
		)

		api.sendGuildError(player, "Black Market purchase completed successfully.")
		marketApi.send(player)
	end

	return marketApi
end

return {
	create = create
}
