// Copyright 2022 The Forgotten Server Authors. All rights reserved.
// Use of this source code is governed by the GPL-2.0 License that can be found in the LICENSE file.

#include "otpch.h"

#include "iomarket.h"

#include "configmanager.h"
#include "databasetasks.h"
#include "fileloader.h"
#include "iologindata.h"
#include "game.h"
#include "scheduler.h"

#include <fmt/format.h>
#include <unordered_map>
#include <vector>

extern ConfigManager g_config;
extern Game g_game;

MarketOfferList IOMarket::getActiveOffers(MarketAction_t action, uint16_t itemId)
{
	MarketOfferList offerList;

	DBResult_ptr result = Database::getInstance().storeQuery(fmt::format("SELECT `id`, `amount`, `price`, `created`, `anonymous`, `currency`, `attributes`, (SELECT `name` FROM `players` WHERE `id` = `player_id`) AS `player_name` FROM `market_offers` WHERE `sale` = {:d} AND `itemtype` = {:d}", action, itemId));
	if (!result) {
		return offerList;
	}

	const int32_t marketOfferDuration = g_config.getNumber(ConfigManager::MARKET_OFFER_DURATION);

	do {
		MarketOffer offer;
		offer.amount = result->getNumber<uint16_t>("amount");
		offer.price = result->getNumber<uint64_t>("price");
		offer.timestamp = result->getNumber<uint32_t>("created") + marketOfferDuration;
		offer.counter = result->getNumber<uint32_t>("id") & 0xFFFF;
		offer.itemId = itemId;
		offer.currency = static_cast<MarketCurrency_t>(result->getNumber<uint16_t>("currency"));
		unsigned long attrSize = 0;
		const char* attr = result->getStream("attributes", attrSize);
		if (attr && attrSize > 0) {
			offer.hasAttributes = true;
			offer.attributes.assign(attr, attrSize);
		}
		if (result->getNumber<uint16_t>("anonymous") == 0) {
			offer.playerName = result->getString("player_name");
		} else {
			offer.playerName = "Anonymous";
		}
		offerList.push_back(offer);
	} while (result->next());
	return offerList;
}

MarketOfferList IOMarket::getOwnOffers(MarketAction_t action, uint32_t playerId)
{
	MarketOfferList offerList;

	const int32_t marketOfferDuration = g_config.getNumber(ConfigManager::MARKET_OFFER_DURATION);

	DBResult_ptr result = Database::getInstance().storeQuery(fmt::format("SELECT `id`, `amount`, `price`, `created`, `itemtype`, `currency`, `attributes` FROM `market_offers` WHERE `player_id` = {:d} AND `sale` = {:d}", playerId, action));
	if (!result) {
		return offerList;
	}

	do {
		MarketOffer offer;
		offer.amount = result->getNumber<uint16_t>("amount");
		offer.price = result->getNumber<uint64_t>("price");
		offer.timestamp = result->getNumber<uint32_t>("created") + marketOfferDuration;
		offer.counter = result->getNumber<uint32_t>("id") & 0xFFFF;
		offer.itemId = result->getNumber<uint16_t>("itemtype");
		offer.currency = static_cast<MarketCurrency_t>(result->getNumber<uint16_t>("currency"));
		unsigned long attrSize = 0;
		const char* attr = result->getStream("attributes", attrSize);
		if (attr && attrSize > 0) {
			offer.hasAttributes = true;
			offer.attributes.assign(attr, attrSize);
		}
		offerList.push_back(offer);
	} while (result->next());
	return offerList;
}

HistoryMarketOfferList IOMarket::getOwnHistory(MarketAction_t action, uint32_t playerId)
{
	HistoryMarketOfferList offerList;

	DBResult_ptr result = Database::getInstance().storeQuery(fmt::format("SELECT `itemtype`, `amount`, `price`, `currency`, `expires_at`, `state` FROM `market_history` WHERE `player_id` = {:d} AND `sale` = {:d}", playerId, action));
	if (!result) {
		return offerList;
	}

	do {
		HistoryMarketOffer offer;
		offer.itemId = result->getNumber<uint16_t>("itemtype");
		offer.amount = result->getNumber<uint16_t>("amount");
		offer.price = result->getNumber<uint64_t>("price");
		offer.timestamp = result->getNumber<uint32_t>("expires_at");

		MarketOfferState_t offerState = static_cast<MarketOfferState_t>(result->getNumber<uint16_t>("state"));
		if (offerState == OFFERSTATE_ACCEPTEDEX) {
			offerState = OFFERSTATE_ACCEPTED;
		}

		offer.currency = static_cast<MarketCurrency_t>(result->getNumber<uint16_t>("currency"));
		offer.state = offerState;

		offerList.push_back(offer);
	} while (result->next());
	return offerList;
}

std::unordered_set<uint32_t> offlinePlayers;

void IOMarket::processExpiredOffers(DBResult_ptr result, bool)
{
    if (!result) {
        return;
    }

    Database& db = Database::getInstance();
    int32_t offerDuration = g_config.getNumber(ConfigManager::MARKET_OFFER_DURATION);

    std::unordered_map<uint32_t, Player*> playerCache;

    std::unordered_map<uint32_t, uint64_t> refundMoney;

    std::vector<uint32_t> offersToDelete;
    offersToDelete.reserve(256);

    auto getOfflinePlayer = [&](uint32_t guid) -> Player*
    {
        auto it = playerCache.find(guid);
        if (it != playerCache.end())
            return it->second;

        Player* p = g_game.getPlayerByGUID(guid);
        if (p) {
            playerCache[guid] = p;
            return p;
        }

        p = new Player(nullptr);
		if (!IOLoginData::loadPlayerById(p, guid)) {
			delete p;
			return nullptr;
		}

		playerCache[guid] = p;
		offlinePlayers.insert(guid);
		return p;
    };

    do {
        uint32_t id       = result->getNumber<uint32_t>("id");
        uint32_t guid     = result->getNumber<uint32_t>("player_id");
        uint16_t sale     = result->getNumber<uint16_t>("sale");
        uint16_t itemtype = result->getNumber<uint16_t>("itemtype");
        uint16_t amount   = result->getNumber<uint16_t>("amount");
        uint64_t price    = result->getNumber<uint64_t>("price");
        uint32_t created  = result->getNumber<uint32_t>("created");
        uint16_t currency = result->getNumber<uint16_t>("currency");
        unsigned long attrSize = 0;
        const char* attr = result->getStream("attributes", attrSize);

        offersToDelete.push_back(id);

    db.executeQuery(fmt::format(
            "INSERT INTO `market_history` "
            "(`player_id`, `sale`, `itemtype`, `amount`, `price`, `currency`, `expires_at`, `inserted`, `state`) "
            "VALUES ({:d}, {:d}, {:d}, {:d}, {:d}, {:d}, {:d}, {:d}, {:d})",
            guid,
            sale,
            itemtype,
            amount,
            price,
            currency,
            created + offerDuration,
            time(nullptr),
            OFFERSTATE_EXPIRED));

        if (sale == 1) {
            Player* player = getOfflinePlayer(guid);
            if (!player)
                continue;

            const ItemType& it = Item::items[itemtype];
            if (it.id == 0)
                continue;

            uint16_t remaining = amount;

            if (attr && attrSize > 0) {
                Item* newItem = Item::CreateItem(itemtype, amount);
                if (newItem) {
                    PropStream propStream;
                    propStream.init(attr, attrSize);
                    if (!newItem->unserializeAttr(propStream)) {
                        std::cout << "WARNING: Serialize error in IOMarket::processExpiredOffers" << std::endl;
                    }
                    g_game.internalAddItem(player->getInbox(), newItem, INDEX_WHEREEVER, FLAG_NOLIMIT);
                }
                continue;
            }

            while (remaining > 0) {
                uint16_t stack = it.stackable ? std::min<uint16_t>(remaining, 100) : 1;
                remaining -= stack;

                Item* newItem = Item::CreateItem(itemtype, stack);
                if (!newItem)
                    continue;

                g_game.internalAddItem(player->getInbox(), newItem, INDEX_WHEREEVER, FLAG_NOLIMIT);
            }

        } else if (currency == MARKETCURRENCY_PREMIUM_POINTS) {
            uint32_t accountId = IOLoginData::getAccountIdByPlayerId(guid);
            if (accountId != 0) {
                db.executeQuery(fmt::format("UPDATE `znote_accounts` SET `points` = `points` + {:d} WHERE `id` = {:d}", static_cast<uint64_t>(price) * amount, accountId));
            }
        } else {
            refundMoney[guid] += static_cast<uint64_t>(price) * amount;
        }

    } while (result->next());

    if (!offersToDelete.empty()) {
        std::string ids;
        ids.reserve(offersToDelete.size() * 6);

        for (uint32_t id : offersToDelete) {
            ids += std::to_string(id) + ",";
        }
        ids.pop_back();

        db.executeQuery("DELETE FROM `market_offers` WHERE `id` IN (" + ids + ")");
    }

    for (auto& it : refundMoney) {
        uint32_t guid = it.first;
        uint64_t amount = it.second;

        Player* pl = g_game.getPlayerByGUID(guid);
        if (pl) {
            pl->setBankBalance(pl->getBankBalance() + amount);
        } else {
            IOLoginData::increaseBankBalance(guid, amount);
        }
    }

    for (auto& it : playerCache) {
		uint32_t guid = it.first;
		Player* p = it.second;

		if (p && offlinePlayers.count(guid)) {
			IOLoginData::savePlayer(p);
			delete p;
		}
	}
}

void IOMarket::checkExpiredOffers()
{
    const time_t lastExpireDate = time(nullptr) - g_config.getNumber(ConfigManager::MARKET_OFFER_DURATION);

    int32_t maxBatch = g_config.getNumber(ConfigManager::MARKET_EXPIRE_BATCH_SIZE);
	if (maxBatch <= 0) {
		maxBatch = 500; // fallback if not precised on config.lua to 500 items at time
	}

    g_databaseTasks.addTask(fmt::format(
        "SELECT `id`, `amount`, `price`, `itemtype`, `player_id`, `sale`, `created`, `currency`, `attributes` "
        "FROM `market_offers` WHERE `created` <= {:d} ORDER BY `id` LIMIT {:d}",
        lastExpireDate, maxBatch),
        IOMarket::processExpiredOffers, true);

    int32_t intervalMinutes = g_config.getNumber(ConfigManager::CHECK_EXPIRED_MARKET_OFFERS_EACH_MINUTES);
    if (intervalMinutes > 0) {
        g_scheduler.addEvent(
            createSchedulerTask(intervalMinutes * 60 * 1000,
                std::bind(IOMarket::checkExpiredOffers))
        );
    }
}

uint32_t IOMarket::getPlayerOfferCount(uint32_t playerId)
{
	DBResult_ptr result = Database::getInstance().storeQuery(fmt::format("SELECT COUNT(*) AS `count` FROM `market_offers` WHERE `player_id` = {:d}", playerId));
	if (!result) {
		return 0;
	}
	return result->getNumber<int32_t>("count");
}

MarketOfferEx IOMarket::getOfferByCounter(uint32_t timestamp, uint16_t counter)
{
	MarketOfferEx offer;

	const int32_t created = timestamp - g_config.getNumber(ConfigManager::MARKET_OFFER_DURATION);

	DBResult_ptr result = Database::getInstance().storeQuery(fmt::format("SELECT `id`, `sale`, `itemtype`, `amount`, `created`, `price`, `player_id`, `anonymous`, `currency`, `attributes`, (SELECT `name` FROM `players` WHERE `id` = `player_id`) AS `player_name` FROM `market_offers` WHERE `created` = {:d} AND (`id` & 65535) = {:d} LIMIT 1", created, counter));
	if (!result) {
		offer.id = 0;
		offer.playerId = 0;
		return offer;
	}

	offer.id = result->getNumber<uint32_t>("id");
	offer.type = static_cast<MarketAction_t>(result->getNumber<uint16_t>("sale"));
	offer.amount = result->getNumber<uint16_t>("amount");
	offer.counter = result->getNumber<uint32_t>("id") & 0xFFFF;
	offer.timestamp = result->getNumber<uint32_t>("created");
	offer.price = result->getNumber<uint64_t>("price");
	offer.itemId = result->getNumber<uint16_t>("itemtype");
	offer.playerId = result->getNumber<uint32_t>("player_id");
	offer.currency = static_cast<MarketCurrency_t>(result->getNumber<uint16_t>("currency"));
	unsigned long attrSize = 0;
	const char* attr = result->getStream("attributes", attrSize);
	if (attr && attrSize > 0) {
		offer.hasAttributes = true;
		offer.attributes.assign(attr, attrSize);
	}
	if (result->getNumber<uint16_t>("anonymous") == 0) {
		offer.playerName = result->getString("player_name");
	} else {
		offer.playerName = "Anonymous";
	}
	return offer;
}

void IOMarket::createOffer(uint32_t playerId, MarketAction_t action, uint32_t itemId, uint16_t amount, uint64_t price, bool anonymous, MarketCurrency_t currency, const std::string& attributes)
{
	Database& db = Database::getInstance();
	db.executeQuery(fmt::format("INSERT INTO `market_offers` (`player_id`, `sale`, `itemtype`, `amount`, `price`, `created`, `anonymous`, `currency`, `attributes`) VALUES ({:d}, {:d}, {:d}, {:d}, {:d}, {:d}, {:d}, {:d}, {:s})", playerId, std::to_string(action), itemId, amount, price, time(nullptr), anonymous, static_cast<uint16_t>(currency), attributes.empty() ? std::string("NULL") : db.escapeBlob(attributes.data(), attributes.size())));
}

void IOMarket::acceptOffer(uint32_t offerId, uint16_t amount)
{
	Database::getInstance().executeQuery(fmt::format("UPDATE `market_offers` SET `amount` = `amount` - {:d} WHERE `id` = {:d}", std::to_string(amount), offerId));
}

void IOMarket::deleteOffer(uint32_t offerId)
{
	Database::getInstance().executeQuery(fmt::format("DELETE FROM `market_offers` WHERE `id` = {:d}", offerId));
}

void IOMarket::appendHistory(uint32_t playerId, MarketAction_t type, uint16_t itemId, uint16_t amount, uint64_t price, time_t timestamp, MarketOfferState_t state, MarketCurrency_t currency)
{
	g_databaseTasks.addTask(fmt::format("INSERT INTO `market_history` (`player_id`, `sale`, `itemtype`, `amount`, `price`, `currency`, `expires_at`, `inserted`, `state`) VALUES ({}, {}, {}, {}, {}, {}, {}, {}, {})", playerId, type, itemId, amount, price, static_cast<uint16_t>(currency), timestamp, time(nullptr), state));
}

bool IOMarket::moveOfferToHistory(uint32_t offerId, MarketOfferState_t state)
{
	const int32_t marketOfferDuration = g_config.getNumber(ConfigManager::MARKET_OFFER_DURATION);

	Database& db = Database::getInstance();

	DBResult_ptr result = db.storeQuery(fmt::format("SELECT `player_id`, `sale`, `itemtype`, `amount`, `price`, `created`, `currency` FROM `market_offers` WHERE `id` = {:d}", offerId));
	if (!result) {
		return false;
	}

	if (!db.executeQuery(fmt::format("DELETE FROM `market_offers` WHERE `id` = {:d}", offerId))) {
		return false;
	}

	appendHistory(result->getNumber<uint32_t>("player_id"), static_cast<MarketAction_t>(result->getNumber<uint16_t>("sale")), result->getNumber<uint16_t>("itemtype"), result->getNumber<uint16_t>("amount"), result->getNumber<uint64_t>("price"), result->getNumber<uint32_t>("created") + marketOfferDuration, state, static_cast<MarketCurrency_t>(result->getNumber<uint16_t>("currency")));
	return true;
}

void IOMarket::updateStatistics()
{
	DBResult_ptr result = Database::getInstance().storeQuery(fmt::format("SELECT `sale` AS `sale`, `itemtype` AS `itemtype`, COUNT(`price`) AS `num`, MIN(`price`) AS `min`, MAX(`price`) AS `max`, SUM(`price`) AS `sum` FROM `market_history` WHERE `state` = {:d} AND `currency` = {:d} GROUP BY `itemtype`, `sale`", OFFERSTATE_ACCEPTED, static_cast<uint16_t>(MARKETCURRENCY_GOLD)));
	if (!result) {
		return;
	}

	do {
		MarketStatistics* statistics;
		if (result->getNumber<uint16_t>("sale") == MARKETACTION_BUY) {
			statistics = &purchaseStatistics[result->getNumber<uint16_t>("itemtype")];
		} else {
			statistics = &saleStatistics[result->getNumber<uint16_t>("itemtype")];
		}

		statistics->numTransactions = result->getNumber<uint32_t>("num");
		statistics->lowestPrice = result->getNumber<uint64_t>("min");
		statistics->totalPrice = result->getNumber<uint64_t>("sum");
		statistics->highestPrice = result->getNumber<uint64_t>("max");
	} while (result->next());
}

MarketStatistics* IOMarket::getPurchaseStatistics(uint16_t itemId)
{
	auto it = purchaseStatistics.find(itemId);
	if (it == purchaseStatistics.end()) {
		return nullptr;
	}
	return &it->second;
}

MarketStatistics* IOMarket::getSaleStatistics(uint16_t itemId)
{
	auto it = saleStatistics.find(itemId);
	if (it == saleStatistics.end()) {
		return nullptr;
	}
	return &it->second;
}
