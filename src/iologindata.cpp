// Copyright 2022 The Forgotten Server Authors. All rights reserved.
// Use of this source code is governed by the GPL-2.0 License that can be found in the LICENSE file.

#include "otpch.h"

#include "iologindata.h"
#include "configmanager.h"
#include "game.h"

#include <fmt/format.h>

extern ConfigManager g_config;
extern Game g_game;

namespace {
const std::string PLAYER_CARAVAN_CONTAINER_KEY = "caravan_root";
}

Account IOLoginData::loadAccount(uint32_t accno)
{
	Account account;

	DBResult_ptr result = Database::getInstance().storeQuery(fmt::format("SELECT `id`, `name`, `password`, `type`, `premium_ends_at` FROM `accounts` WHERE `id` = {:d}", accno));
	if (!result) {
		return account;
	}

	account.id = result->getNumber<uint32_t>("id");
	account.name = result->getString("name");
	account.accountType = static_cast<AccountType_t>(result->getNumber<int32_t>("type"));
	account.premiumEndsAt = result->getNumber<time_t>("premium_ends_at");
	return account;
}

std::string decodeSecret(const std::string& secret)
{
	// simple base32 decoding
	std::string key;
	key.reserve(10);

	uint32_t buffer = 0, left = 0;
	for (const auto& ch : secret) {
		buffer <<= 5;
		if (ch >= 'A' && ch <= 'Z') {
			buffer |= (ch & 0x1F) - 1;
		} else if (ch >= '2' && ch <= '7') {
			buffer |= ch - 24;
		} else {
			// if a key is broken, return empty and the comparison
			// will always be false since the token must not be empty
			return {};
		}

		left += 5;
		if (left >= 8) {
			left -= 8;
			key.push_back(static_cast<char>(buffer >> left));
		}
	}

	return key;
}

bool IOLoginData::loginserverAuthentication(const std::string& name, const std::string& password, Account& account)
{
	Database& db = Database::getInstance();

	DBResult_ptr result = db.storeQuery(fmt::format("SELECT `id`, `name`, `password`, `secret`, `type`, `premium_ends_at` FROM `accounts` WHERE `name` = {:s}", db.escapeString(name)));
	if (!result) {
		return false;
	}

	if (transformToSHA1(password) != result->getString("password")) {
		return false;
	}

	account.id = result->getNumber<uint32_t>("id");
	account.name = result->getString("name");
	account.key = decodeSecret(result->getString("secret"));
	account.accountType = static_cast<AccountType_t>(result->getNumber<int32_t>("type"));
	account.premiumEndsAt = result->getNumber<time_t>("premium_ends_at");

	result = db.storeQuery(fmt::format(
		"SELECT `p`.`name`, `p`.`level`, `p`.`vocation`, `p`.`lookbody`, `p`.`lookfeet`, "
		"`p`.`lookhead`, `p`.`looklegs`, `p`.`lookmounthead`, `p`.`lookmountbody`, "
		"`p`.`lookmountlegs`, `p`.`lookmountfeet`, `p`.`looktype`, `p`.`lookaddons`, "
		"COALESCE(`g`.`name`, '') AS `guild_name` FROM `players` AS `p` "
		"LEFT JOIN `guild_membership` AS `gm` ON `gm`.`player_id` = `p`.`id` "
		"LEFT JOIN `guilds` AS `g` ON `g`.`id` = `gm`.`guild_id` "
		"WHERE `p`.`account_id` = {:d} AND `p`.`deletion` = 0 ORDER BY `p`.`name` ASC",
		account.id));
	if (result) {
			do {
				Character character;
				
				character.name = result->getString("name");
				character.guildName = result->getString("guild_name");
				character.level = result->getNumber<uint32_t>("level");
				character.vocation = result->getNumber<uint16_t>("vocation");
				
				character.outfit.lookType = result->getNumber<uint16_t>("looktype");
				character.outfit.lookHead = result->getNumber<uint16_t>("lookhead");
				character.outfit.lookBody = result->getNumber<uint16_t>("lookbody");
				character.outfit.lookLegs = result->getNumber<uint16_t>("looklegs");
				character.outfit.lookFeet = result->getNumber<uint16_t>("lookfeet");
				character.outfit.lookMountHead = result->getNumber<uint16_t>("lookmounthead");
				character.outfit.lookMountBody = result->getNumber<uint16_t>("lookmountbody");
				character.outfit.lookMountLegs = result->getNumber<uint16_t>("lookmountlegs");
				character.outfit.lookMountFeet = result->getNumber<uint16_t>("lookmountfeet");
				character.outfit.lookAddons = result->getNumber<uint16_t>("lookaddons");

				account.characters.push_back(character);
		} while (result->next());
	}
	return true;
}

uint32_t IOLoginData::gameworldAuthentication(const std::string& accountName, const std::string& password, std::string& characterName, std::string& token, uint32_t tokenTime)
{
	Database& db = Database::getInstance();

	DBResult_ptr result = db.storeQuery(fmt::format("SELECT `id`, `password`, `secret` FROM `accounts` WHERE `name` = {:s}", db.escapeString(accountName)));
	if (!result) {
		return 0;
	}

	std::string secret = decodeSecret(result->getString("secret"));
	if (!secret.empty()) {
		if (token.empty()) {
			return 0;
		}

		bool tokenValid = token == generateToken(secret, tokenTime) || token == generateToken(secret, tokenTime - 1) || token == generateToken(secret, tokenTime + 1);
		if (!tokenValid) {
			return 0;
		}
	}

	if (transformToSHA1(password) != result->getString("password")) {
		return 0;
	}

	uint32_t accountId = result->getNumber<uint32_t>("id");

	result = db.storeQuery(fmt::format("SELECT `name` FROM `players` WHERE `name` = {:s} AND `account_id` = {:d} AND `deletion` = 0", db.escapeString(characterName), accountId));
	if (!result) {
		return 0;
	}

	characterName = result->getString("name");
	return accountId;
}

uint32_t IOLoginData::getAccountIdByPlayerName(const std::string& playerName)
{
	Database& db = Database::getInstance();

	DBResult_ptr result = db.storeQuery(fmt::format("SELECT `account_id` FROM `players` WHERE `name` = {:s}", db.escapeString(playerName)));
	if (!result) {
		return 0;
	}
	return result->getNumber<uint32_t>("account_id");
}

uint32_t IOLoginData::getAccountIdByPlayerId(uint32_t playerId)
{
	Database& db = Database::getInstance();

	DBResult_ptr result = db.storeQuery(fmt::format("SELECT `account_id` FROM `players` WHERE `id` = {:d}", playerId));
	if (!result) {
		return 0;
	}
	return result->getNumber<uint32_t>("account_id");
}

AccountType_t IOLoginData::getAccountType(uint32_t accountId)
{
	DBResult_ptr result = Database::getInstance().storeQuery(fmt::format("SELECT `type` FROM `accounts` WHERE `id` = {:d}", accountId));
	if (!result) {
		return ACCOUNT_TYPE_NORMAL;
	}
	return static_cast<AccountType_t>(result->getNumber<uint16_t>("type"));
}

void IOLoginData::setAccountType(uint32_t accountId, AccountType_t accountType)
{
	Database::getInstance().executeQuery(fmt::format("UPDATE `accounts` SET `type` = {:d} WHERE `id` = {:d}", static_cast<uint16_t>(accountType), accountId));
}

void IOLoginData::updateOnlineStatus(uint32_t guid, bool login)
{
	if (g_config.getBoolean(ConfigManager::ALLOW_CLONES)) {
		return;
	}

	if (login) {
		Database::getInstance().executeQuery(fmt::format("INSERT INTO `players_online` VALUES ({:d})", guid));
	} else {
		Database::getInstance().executeQuery(fmt::format("DELETE FROM `players_online` WHERE `player_id` = {:d}", guid));
	}
}

bool IOLoginData::preloadPlayer(Player* player, const std::string& name)
{
	Database& db = Database::getInstance();

	DBResult_ptr result = db.storeQuery(fmt::format("SELECT `p`.`id`, `p`.`account_id`, `p`.`group_id`, `a`.`type`, `a`.`premium_ends_at` FROM `players` as `p` JOIN `accounts` as `a` ON `a`.`id` = `p`.`account_id` WHERE `p`.`name` = {:s} AND `p`.`deletion` = 0", db.escapeString(name)));
	if (!result) {
		return false;
	}

	player->setGUID(result->getNumber<uint32_t>("id"));
	Group* group = g_game.groups.getGroup(result->getNumber<uint16_t>("group_id"));
	if (!group) {
		std::cout << "[Error - IOLoginData::preloadPlayer] " << player->name << " has Group ID " << result->getNumber<uint16_t>("group_id") << " which doesn't exist." << std::endl;
		return false;
	}
	player->setGroup(group);
	player->accountNumber = result->getNumber<uint32_t>("account_id");
	player->accountType = static_cast<AccountType_t>(result->getNumber<uint16_t>("type"));
	player->premiumEndsAt = result->getNumber<time_t>("premium_ends_at");
	return true;
}

bool IOLoginData::loadPlayerById(Player* player, uint32_t id)
{
	Database& db = Database::getInstance();
	return loadPlayer(player, db.storeQuery(fmt::format("SELECT `id`, `name`, `account_id`, `group_id`, `sex`, `vocation`, `experience`, `level`, `maglevel`, `health`, `healthmax`, `blessings`, `mana`, `manamax`, `manaspent`, `soul`, `lookbody`, `lookfeet`, `lookhead`, `looklegs`, `lookmounthead`, `lookmountbody`, `lookmountlegs`, `lookmountfeet`, `looktype`, `lookaddons`, `posx`, `posy`, `posz`, `cap`, `lastlogin`, `lastlogout`, `lastip`, `conditions`, `skulltime`, `skull`, `town_id`, `balance`, `offlinetraining_time`, `offlinetraining_skill`, `stamina`, `skill_fist`, `skill_fist_tries`, `skill_club`, `skill_club_tries`, `skill_sword`, `skill_sword_tries`, `skill_axe`, `skill_axe_tries`, `skill_dist`, `skill_dist_tries`, `skill_shielding`, `skill_shielding_tries`, `skill_fishing`, `skill_fishing_tries`, `skill_crafting`, `skill_crafting_tries`, `skill_woodcutting`, `skill_woodcutting_tries`, `skill_mining`, `skill_mining_tries`, `skill_herbalist`, `skill_herbalist_tries`, `direction`, `autoloot`, `battlepass`, `stat_str`, `stat_int`, `stat_dex`, `stat_vit`, `stat_spr`, `stat_wis`, `skill_armorsmith`, `skill_armorsmith_tries`, `skill_weaponsmith`, `skill_weaponsmith_tries`, `skill_jewelsmith`, `skill_jewelsmith_tries` FROM `players` WHERE `id` = {:d}", id)));
}

bool IOLoginData::loadPlayerByName(Player* player, const std::string& name)
{
	Database& db = Database::getInstance();
	return loadPlayer(player, db.storeQuery(fmt::format("SELECT `id`, `name`, `account_id`, `group_id`, `sex`, `vocation`, `experience`, `level`, `maglevel`, `health`, `healthmax`, `blessings`, `mana`, `manamax`, `manaspent`, `soul`, `lookbody`, `lookfeet`, `lookhead`, `looklegs`, `lookmounthead`, `lookmountbody`, `lookmountlegs`, `lookmountfeet`, `looktype`, `lookaddons`, `posx`, `posy`, `posz`, `cap`, `lastlogin`, `lastlogout`, `lastip`, `conditions`, `skulltime`, `skull`, `town_id`, `balance`, `offlinetraining_time`, `offlinetraining_skill`, `stamina`, `skill_fist`, `skill_fist_tries`, `skill_club`, `skill_club_tries`, `skill_sword`, `skill_sword_tries`, `skill_axe`, `skill_axe_tries`, `skill_dist`, `skill_dist_tries`, `skill_shielding`, `skill_shielding_tries`, `skill_fishing`, `skill_fishing_tries`, `skill_crafting`, `skill_crafting_tries`, `skill_woodcutting`, `skill_woodcutting_tries`, `skill_mining`, `skill_mining_tries`,  `skill_herbalist`, `skill_herbalist_tries`, `direction`, `autoloot`, `battlepass`, `stat_str`, `stat_int`, `stat_dex`, `stat_vit`, `stat_spr`, `stat_wis`, `skill_armorsmith`, `skill_armorsmith_tries`, `skill_weaponsmith`, `skill_weaponsmith_tries`, `skill_jewelsmith`, `skill_jewelsmith_tries` FROM `players` WHERE `name` = {:s}", db.escapeString(name))));
}

static GuildWarVector getWarList(uint32_t guildId)
{
	DBResult_ptr result = Database::getInstance().storeQuery(fmt::format("SELECT `guild1`, `guild2` FROM `guild_wars` WHERE (`guild1` = {:d} OR `guild2` = {:d}) AND `ended` = 0 AND `status` = 1", guildId, guildId));
	if (!result) {
		return {};
	}

	GuildWarVector guildWarVector;
	do {
		uint32_t guild1 = result->getNumber<uint32_t>("guild1");
		if (guildId != guild1) {
			guildWarVector.push_back(guild1);
		} else {
			guildWarVector.push_back(result->getNumber<uint32_t>("guild2"));
		}
	} while (result->next());
	return std::move(guildWarVector);
}

bool IOLoginData::loadPlayer(Player* player, DBResult_ptr result)
{
	if (!result) {
		return false;
	}

	Database& db = Database::getInstance();

	uint32_t accno = result->getNumber<uint32_t>("account_id");
	Account acc = loadAccount(accno);

	player->setGUID(result->getNumber<uint32_t>("id"));
	player->name = result->getString("name");
	player->accountNumber = accno;

	player->accountType = acc.accountType;

	player->premiumEndsAt = acc.premiumEndsAt;

	Group* group = g_game.groups.getGroup(result->getNumber<uint16_t>("group_id"));
	if (!group) {
		std::cout << "[Error - IOLoginData::loadPlayer] " << player->name << " has Group ID " << result->getNumber<uint16_t>("group_id") << " which doesn't exist" << std::endl;
		return false;
	}
	player->setGroup(group);

	player->bankBalance = result->getNumber<uint64_t>("balance");

	player->setSex(static_cast<PlayerSex_t>(result->getNumber<uint16_t>("sex")));
	player->level = std::max<uint32_t>(1, result->getNumber<uint32_t>("level"));

	uint64_t experience = result->getNumber<uint64_t>("experience");

	uint64_t currExpCount = Player::getExpForLevel(player->level);
	uint64_t nextExpCount = Player::getExpForLevel(player->level + 1);
	if (experience < currExpCount || experience > nextExpCount) {
		experience = currExpCount;
	}

	player->experience = experience;

	if (currExpCount < nextExpCount) {
		player->levelPercent = Player::getPercentLevel(player->experience - currExpCount, nextExpCount - currExpCount);
	} else {
		player->levelPercent = 0;
	}

	player->soul = result->getNumber<uint16_t>("soul");
	player->capacity = result->getNumber<uint32_t>("cap") * 100;
	player->blessings = result->getNumber<uint16_t>("blessings");

	unsigned long conditionsSize;
	const char* conditions = result->getStream("conditions", conditionsSize);
	PropStream propStream;
	propStream.init(conditions, conditionsSize);

	Condition* condition = Condition::createCondition(propStream);
	while (condition) {
		if (condition->unserialize(propStream)) {
			player->storedConditionList.push_front(condition);
		} else {
			delete condition;
		}
		condition = Condition::createCondition(propStream);
	}

	// unserialize battlepass
	unsigned long battlepassSize = 0;
	const char* battlepass = result->getStream("battlepass", battlepassSize);

	if (!battlepass || battlepassSize == 0) {
		// No data => new battlepass based on current level
		player->resetBattlepass();
	} else {
		PropStream propStreamBattlepass;
		propStreamBattlepass.init(battlepass, battlepassSize);

		bool ok = true;

		uint32_t battlepassExperience = 0;
		ok = ok && propStreamBattlepass.read<uint32_t>(battlepassExperience);

		uint16_t battlepassLevel = 1;
		ok = ok && propStreamBattlepass.read<uint16_t>(battlepassLevel);

		uint8_t battlepassPremium = 0;
		ok = ok && propStreamBattlepass.read<uint8_t>(battlepassPremium);

		uint8_t battlepassCounterTypes = 0;
		ok = ok && propStreamBattlepass.read<uint8_t>(battlepassCounterTypes);

		if (!ok || battlepassCounterTypes == 0) {
			player->resetBattlepass();
		} else {
			player->battlepass->setExperience(battlepassExperience);
			player->battlepass->setLevel(battlepassLevel);
			player->battlepass->setPremium(battlepassPremium != 0);

			for (uint8_t i = 0; i < battlepassCounterTypes; ++i) {
				uint8_t battlepassMainId = 0;
				if (!propStreamBattlepass.read<uint8_t>(battlepassMainId)) {
					ok = false;
					break;
				}

				uint8_t battlepassCounterIds = 0;
				if (!propStreamBattlepass.read<uint8_t>(battlepassCounterIds)) {
					ok = false;
					break;
				}

				BattlePassType_t battlepassType = static_cast<BattlePassType_t>(battlepassMainId);
				if (battlepassType < BATTLEPASS_TYPE_FIRST || battlepassType > BATTLEPASS_TYPE_LAST) {
					ok = false;
					break;
				}

				for (uint8_t j = 0; j < battlepassCounterIds; ++j) {
					uint16_t battlepassId = 0;
					uint64_t battlepassCooldown = 0;
					uint32_t battlepassAmount = 0;
					uint8_t battlepassShuffled = 0;

					if (!propStreamBattlepass.read<uint16_t>(battlepassId) ||
						!propStreamBattlepass.read<uint64_t>(battlepassCooldown) ||
						!propStreamBattlepass.read<uint32_t>(battlepassAmount) ||
						!propStreamBattlepass.read<uint8_t>(battlepassShuffled)) {
						ok = false;
						break;
					}

					bool shuffled = (battlepassShuffled == 1);
					std::any value;

					uint8_t valueType = 0;
					if (!propStreamBattlepass.read<uint8_t>(valueType)) {
						ok = false;
						break;
					}

					if (valueType == ItemAttributesStruct::Type::INTEGER) {
						uint16_t v16 = 0;
						if (!propStreamBattlepass.read<uint16_t>(v16)) {
							ok = false;
							break;
						}
						value = v16;
					} 
					else if (valueType == ItemAttributesStruct::Type::STRING) {
						std::string s;
						if (!propStreamBattlepass.readString(s)) {
							ok = false;
							break;
						}
						value = s;
					} 
					else if (valueType != 0) {
						ok = false;
						break;
					}

					player->addBattlepassQuest(
						battlepassType,
						static_cast<BattlePassQuests_t>(battlepassId),
						battlepassAmount,
						battlepassCooldown,
						value,
						shuffled
					);
				}

				if (!ok) {
					break;
				}
			}

			if (!ok) {
				std::cout << "[Warning - IOLoginData::loadPlayer] Invalid battlepass blob for "
						<< player->getName() << ", resetting." << std::endl;
				player->resetBattlepass();
			}
		}
	}

	// unserialize loot list
	unsigned long autolootSize;
	const char* autoloot = result->getStream("autoloot", autolootSize);
	PropStream propStreamAutoloot;
	propStreamAutoloot.init(autoloot, autolootSize);
	uint16_t autoLootSize;
	if (propStreamAutoloot.read<uint16_t>(autoLootSize)) {
		for (uint16_t i = 0; i < autoLootSize; ++i) {
			uint16_t itemId;
			if (propStreamAutoloot.read<uint16_t>(itemId) && itemId != 0) {
				player->autoLootItems.push_back(itemId);
			}
		}
	}

	if (!player->setVocation(result->getNumber<uint16_t>("vocation"))) {
		std::cout << "[Error - IOLoginData::loadPlayer] " << player->name << " has Vocation ID " << result->getNumber<uint16_t>("vocation") << " which doesn't exist" << std::endl;
		return false;
	}

	player->mana = result->getNumber<uint32_t>("mana");
	player->manaMax = result->getNumber<uint32_t>("manamax");
	player->magLevel = result->getNumber<uint32_t>("maglevel");

	uint64_t nextManaCount = player->vocation->getReqMana(player->magLevel + 1);
	uint64_t manaSpent = result->getNumber<uint64_t>("manaspent");
	if (manaSpent > nextManaCount) {
		manaSpent = 0;
	}

	player->manaSpent = manaSpent;
	player->magLevelPercent = Player::getPercentLevel(player->manaSpent, nextManaCount);

	player->health = result->getNumber<int32_t>("health");
	player->healthMax = result->getNumber<int32_t>("healthmax");

	player->defaultOutfit.lookType = result->getNumber<uint16_t>("looktype");
	player->defaultOutfit.lookHead = result->getNumber<uint16_t>("lookhead");
	player->defaultOutfit.lookBody = result->getNumber<uint16_t>("lookbody");
	player->defaultOutfit.lookLegs = result->getNumber<uint16_t>("looklegs");
	player->defaultOutfit.lookFeet = result->getNumber<uint16_t>("lookfeet");
	player->defaultOutfit.lookMountHead = result->getNumber<uint16_t>("lookmounthead");
	player->defaultOutfit.lookMountBody = result->getNumber<uint16_t>("lookmountbody");
	player->defaultOutfit.lookMountLegs = result->getNumber<uint16_t>("lookmountlegs");
	player->defaultOutfit.lookMountFeet = result->getNumber<uint16_t>("lookmountfeet");
	player->defaultOutfit.lookAddons = result->getNumber<uint16_t>("lookaddons");
	player->currentOutfit = player->defaultOutfit;
	player->direction = static_cast<Direction> (result->getNumber<uint16_t>("direction"));

	if (g_game.getWorldType() != WORLD_TYPE_PVP_ENFORCED) {
		const time_t skullSeconds = result->getNumber<time_t>("skulltime") - time(nullptr);
		if (skullSeconds > 0) {
			//ensure that we round up the number of ticks
			player->skullTicks = (skullSeconds + 2);

			uint16_t skull = result->getNumber<uint16_t>("skull");
			if (skull == SKULL_RED) {
				player->skull = SKULL_RED;
			} else if (skull == SKULL_BLACK) {
				player->skull = SKULL_BLACK;
			}
		}
	}

	player->loginPosition.x = result->getNumber<uint16_t>("posx");
	player->loginPosition.y = result->getNumber<uint16_t>("posy");
	player->loginPosition.z = result->getNumber<uint16_t>("posz");

	player->lastLoginSaved = result->getNumber<time_t>("lastlogin");
	player->lastLogout = result->getNumber<time_t>("lastlogout");

	player->offlineTrainingTime = result->getNumber<int32_t>("offlinetraining_time") * 1000;
	player->offlineTrainingSkill = result->getNumber<int32_t>("offlinetraining_skill");

	Town* town = g_game.map.towns.getTown(result->getNumber<uint32_t>("town_id"));
	if (!town) {
		std::cout << "[Error - IOLoginData::loadPlayer] " << player->name << " has Town ID " << result->getNumber<uint32_t>("town_id") << " which doesn't exist" << std::endl;
		return false;
	}

	player->town = town;

	const Position& loginPos = player->loginPosition;
	if (loginPos.x == 0 && loginPos.y == 0 && loginPos.z == 0) {
		player->loginPosition = player->getTemplePosition();
	}

	player->staminaMinutes = result->getNumber<uint16_t>("stamina");

	static const std::string skillNames[] = {"skill_fist", "skill_club", "skill_sword", "skill_axe", "skill_dist", "skill_shielding", "skill_fishing", "skill_crafting", "skill_woodcutting", "skill_mining", "skill_herbalist", "skill_armorsmith", "skill_weaponsmith", "skill_jewelsmith"};
	static const std::string skillNameTries[] = {"skill_fist_tries", "skill_club_tries", "skill_sword_tries", "skill_axe_tries", "skill_dist_tries", "skill_shielding_tries", "skill_fishing_tries", "skill_crafting_tries", "skill_woodcutting_tries", "skill_mining_tries", "skill_herbalist_tries", "skill_armorsmith_tries", "skill_weaponsmith_tries", "skill_jewelsmith_tries"};
	static constexpr size_t size = sizeof(skillNames) / sizeof(std::string);
	for (uint8_t i = 0; i < size; ++i) {
		uint16_t skillLevel = result->getNumber<uint16_t>(skillNames[i]);
		uint64_t skillTries = result->getNumber<uint64_t>(skillNameTries[i]);
		uint64_t nextSkillTries = player->vocation->getReqSkillTries(i, skillLevel + 1);
		if (skillTries > nextSkillTries) {
			skillTries = 0;
		}

		player->skills[i].level = skillLevel;
		player->skills[i].tries = skillTries;
		player->skills[i].percent = Player::getPercentLevel(skillTries, nextSkillTries);
	}

	static const std::string charStatNames[] = {"stat_str", "stat_int", "stat_dex", "stat_vit", "stat_spr", "stat_wis"};
	for (auto i = 0; i < CHARSTAT_LAST + 1; ++i) {
		player->charStats[i] = result->getNumber<int16_t>(charStatNames[i]);
	}

	if ((result = db.storeQuery(fmt::format("SELECT `guild_id`, `rank_id`, `nick` FROM `guild_membership` WHERE `player_id` = {:d}", player->getGUID())))) {
		uint32_t guildId = result->getNumber<uint32_t>("guild_id");
		uint32_t playerRankId = result->getNumber<uint32_t>("rank_id");
		player->guildNick = result->getString("nick");

		Guild* guild = g_game.getGuild(guildId);
		if (!guild) {
			guild = IOGuild::loadGuild(guildId);
			if (guild) {
				g_game.addGuild(guild);
			} else {
				std::cout << "[Warning - IOLoginData::loadPlayer] " << player->name << " has Guild ID " << guildId << " which doesn't exist" << std::endl;
			}
		}

		if (guild) {
			player->guild = guild;
			GuildRank_ptr rank = guild->getRankById(playerRankId);
			if (!rank) {
				if ((result = db.storeQuery(fmt::format("SELECT `id`, `name`, `level` FROM `guild_ranks` WHERE `id` = {:d}", playerRankId)))) {
					guild->addRank(result->getNumber<uint32_t>("id"), result->getString("name"), result->getNumber<uint16_t>("level"));
				}

				rank = guild->getRankById(playerRankId);
				if (!rank) {
					player->guild = nullptr;
				}
			}

			player->guildRank = rank;
			player->guildWarVector = getWarList(guildId);

			if ((result = db.storeQuery(fmt::format("SELECT COUNT(*) AS `members` FROM `guild_membership` WHERE `guild_id` = {:d}", guildId)))) {
				guild->setMemberCount(result->getNumber<uint32_t>("members"));
			}
		}
	}

	if ((result = db.storeQuery(fmt::format("SELECT `player_id`, `name` FROM `player_spells` WHERE `player_id` = {:d}", player->getGUID())))) {
		do {
			player->learnedInstantSpellList.emplace_front(result->getString("name"));
		} while (result->next());
	}

	//load inventory items
	ItemMap itemMap;

	if ((result = db.storeQuery(fmt::format("SELECT `pid`, `sid`, `itemtype`, `count`, `attributes` FROM `player_items` WHERE `player_id` = {:d} ORDER BY `sid` DESC", player->getGUID())))) {
		loadItems(itemMap, result);

		for (ItemMap::const_reverse_iterator it = itemMap.rbegin(), end = itemMap.rend(); it != end; ++it) {
			const std::pair<Item*, int32_t>& pair = it->second;
			Item* item = pair.first;
			int32_t pid = pair.second;
			if (pid >= CONST_SLOT_FIRST && pid <= CONST_SLOT_LAST) {
				player->internalAddThing(pid, item);
			} else {
				ItemMap::const_iterator it2 = itemMap.find(pid);
				if (it2 == itemMap.end()) {
					continue;
				}

				Container* container = it2->second.first->getContainer();
				if (container) {
					container->internalAddThing(item);
				}
			}
		}
	}

	//load depot items
	itemMap.clear();

	if ((result = db.storeQuery(fmt::format("SELECT `pid`, `sid`, `itemtype`, `count`, `attributes` FROM `player_depotitems` WHERE `player_id` = {:d} ORDER BY `sid` DESC", player->getGUID())))) {
		loadItems(itemMap, result);

		for (ItemMap::const_reverse_iterator it = itemMap.rbegin(), end = itemMap.rend(); it != end; ++it) {
			const std::pair<Item*, int32_t>& pair = it->second;
			Item* item = pair.first;

			int32_t pid = pair.second;
			if (pid >= 0 && pid < 100) {
				DepotChest* depotChest = player->getDepotChest(pid, true);
				if (depotChest) {
					depotChest->internalAddThing(item);
				}
			} else {
				ItemMap::const_iterator it2 = itemMap.find(pid);
				if (it2 == itemMap.end()) {
					continue;
				}

				Container* container = it2->second.first->getContainer();
				if (container) {
					container->internalAddThing(item);
				}
			}
		}
	}

	// Load reward items
	itemMap.clear();

	if ((result = db.storeQuery(fmt::format("SELECT `sid`, `pid`, `itemtype`, `count`, `attributes` FROM `player_rewarditems` WHERE `player_id` = {:d} ORDER BY `sid` DESC", player->getGUID())))) {
		loadItems(itemMap, result);

		// Map to store containers (bags) for each unique DATE attribute
		std::unordered_map<int64_t, Container*> dateContainers;

		// Get the current time and calculate the time 7 days ago
		time_t now = std::time(nullptr);
		time_t seven_days_ago = now - (7 * 24 * 60 * 60); // 7 days in seconds
		

		for (ItemMap::const_reverse_iterator it = itemMap.rbegin(), end = itemMap.rend(); it != end; ++it) {
			const std::pair<Item*, uint32_t>& pair = it->second;
			Item* item = pair.first;

			int64_t rewardDate = item->getIntAttr(ITEM_ATTRIBUTE_DATE);

			// Skip items older than 7 days
			if (rewardDate < static_cast<int64_t>(seven_days_ago)) {
				continue;
			}

			// Create or get existing container for the given DATE attribute
			Container* container = nullptr;
			auto containerIt = dateContainers.find(rewardDate);
			if (containerIt != dateContainers.end()) {
				container = containerIt->second;
			}
			else {
				container = new Container(ITEM_REWARD_CONTAINER);
				container->setIntAttr(ITEM_ATTRIBUTE_DATE, rewardDate); // Set the DATE attribute on the container
				container->setIntAttr(ITEM_ATTRIBUTE_REWARDID, item->getIntAttr(ITEM_ATTRIBUTE_REWARDID));
				dateContainers[rewardDate] = container;
			}

			container->internalAddThing(item);
		}

		for (auto& pair : dateContainers) {
			player->getRewardChest().internalAddThing(pair.second);
		}
	}

	//load inbox items
	itemMap.clear();

	if ((result = db.storeQuery(fmt::format("SELECT `pid`, `sid`, `itemtype`, `count`, `attributes` FROM `player_inboxitems` WHERE `player_id` = {:d} ORDER BY `sid` DESC", player->getGUID())))) {
		loadItems(itemMap, result);

		for (ItemMap::const_reverse_iterator it = itemMap.rbegin(), end = itemMap.rend(); it != end; ++it) {
			const std::pair<Item*, int32_t>& pair = it->second;
			Item* item = pair.first;
			int32_t pid = pair.second;

			if (pid >= 0 && pid < 100) {
				Container* container = item->getContainer();
				if (container && item->getCustomAttribute(PLAYER_CARAVAN_CONTAINER_KEY)) {
					player->setCaravanContainer(container);
				} else {
					player->getInbox()->internalAddThing(item);
					item->startDecaying();
				}
			} else {
				ItemMap::const_iterator it2 = itemMap.find(pid);

				if (it2 == itemMap.end()) {
					continue;
				}

				Container* container = it2->second.first->getContainer();
				if (container) {
					container->internalAddThing(item);
				}
			}
		}
	}

	//load store inbox items
	itemMap.clear();

	if ((result = db.storeQuery(fmt::format("SELECT `pid`, `sid`, `itemtype`, `count`, `attributes` FROM `player_storeinboxitems` WHERE `player_id` = {:d} ORDER BY `sid` DESC", player->getGUID())))) {
		loadItems(itemMap, result);

		for (ItemMap::const_reverse_iterator it = itemMap.rbegin(), end = itemMap.rend(); it != end; ++it) {
			const std::pair<Item*, int32_t>& pair = it->second;
			Item* item = pair.first;
			int32_t pid = pair.second;

			if (pid >= 0 && pid < 100) {
				player->getStoreInbox()->internalAddThing(item);
			} else {
				ItemMap::const_iterator it2 = itemMap.find(pid);

				if (it2 == itemMap.end()) {
					continue;
				}

				Container* container = it2->second.first->getContainer();
				if (container) {
					container->internalAddThing(item);
				}
			}
		}
	}

	//load storage map
	if ((result = db.storeQuery(fmt::format("SELECT `key`, `value` FROM `player_storage` WHERE `player_id` = {:d}", player->getGUID())))) {
		do {
			player->addStorageValue(result->getNumber<uint32_t>("key"), result->getNumber<int32_t>("value"), true);
		} while (result->next());
	}

	if ((result = db.storeQuery(fmt::format("SELECT `unlocked_slots`, `hunting_task_unlocked_slots`, `wildcards` FROM `player_prey_resources` WHERE `player_id` = {:d}", player->getGUID())))) {
		player->setPreyUnlockedSlots(result->getNumber<uint16_t>("unlocked_slots"));
		player->setHuntingTaskUnlockedSlots(result->getNumber<uint16_t>("hunting_task_unlocked_slots"));
		player->setPreyWildcards(result->getNumber<uint32_t>("wildcards"));
	}

	if ((result = db.storeQuery(fmt::format(
		"SELECT `slot`, `monster_name`, `look_type`, `look_type_ex`, `look_head`, `look_body`, `look_legs`, `look_feet`, `look_addons`, `look_mount`, `look_wings`, `look_aura`, `look_shader`, `bonus_type`, `bonus_value`, `bonus_grade`, `expires_at`, `free_reroll_at`, `lock_type` FROM `player_prey` WHERE `player_id` = {:d}",
		player->getGUID())))) {
		const time_t now = std::time(nullptr);
		do {
			const uint8_t slotId = result->getNumber<uint16_t>("slot");
			if (slotId >= PREY_SLOT_COUNT) {
				continue;
			}

			PreySlot& preySlot = player->getPreySlot(slotId);
			preySlot.monsterName = result->getString("monster_name");
			preySlot.outfit.lookType = result->getNumber<uint16_t>("look_type");
			preySlot.outfit.lookTypeEx = result->getNumber<uint16_t>("look_type_ex");
			preySlot.outfit.lookHead = result->getNumber<uint16_t>("look_head");
			preySlot.outfit.lookBody = result->getNumber<uint16_t>("look_body");
			preySlot.outfit.lookLegs = result->getNumber<uint16_t>("look_legs");
			preySlot.outfit.lookFeet = result->getNumber<uint16_t>("look_feet");
			preySlot.outfit.lookAddons = result->getNumber<uint16_t>("look_addons");
			preySlot.outfit.lookMount = result->getNumber<uint16_t>("look_mount");
			preySlot.outfit.lookWings = result->getNumber<uint16_t>("look_wings");
			preySlot.outfit.lookAura = result->getNumber<uint16_t>("look_aura");
			preySlot.outfit.lookShader = result->getNumber<uint16_t>("look_shader");
			preySlot.bonusType = result->getNumber<uint16_t>("bonus_type");
			preySlot.bonusValue = result->getNumber<uint16_t>("bonus_value");
			preySlot.bonusGrade = result->getNumber<uint16_t>("bonus_grade");
			preySlot.expiresAt = result->getNumber<time_t>("expires_at");
			preySlot.freeRerollAt = result->getNumber<time_t>("free_reroll_at");
			preySlot.lockType = result->getNumber<uint16_t>("lock_type");
			preySlot.active = preySlot.expiresAt > now && !preySlot.monsterName.empty();
		} while (result->next());
	}

	//load vip list
	if ((result = db.storeQuery(fmt::format("SELECT `player_id` FROM `account_viplist` WHERE `account_id` = {:d}", player->getAccount())))) {
		do {
			player->addVIPInternal(result->getNumber<uint32_t>("player_id"));
		} while (result->next());
	}

	player->updateBaseSpeed();
	player->updateInventoryWeight();
	player->updateItemsLight(true);
	return true;
}

bool IOLoginData::saveItems(const Player* player, const ItemBlockList& itemList, DBInsert& query_insert, PropWriteStream& propWriteStream, std::map<Container*, int>& openContainers)
{
	using ContainerBlock = std::pair<Container*, int32_t>;
	std::list<ContainerBlock> queue;

	int32_t runningId = 100;

	Database& db = Database::getInstance();
	for (const auto& it : itemList) {
		int32_t pid = it.first;
		Item* item = it.second;
		++runningId;

		if (Container* container = item->getContainer()) {
			auto itOpen = openContainers.find(container);
			if (itOpen == openContainers.end()) {
				container->resetAutoOpen();
			} else {
				container->setAutoOpen(itOpen->second);
			}
			queue.emplace_back(container, runningId);
		}

		propWriteStream.clear();
		item->serializeAttr(propWriteStream);

		size_t attributesSize;
		const char* attributes = propWriteStream.getStream(attributesSize);

		if (!query_insert.addRow(fmt::format("{:d}, {:d}, {:d}, {:d}, {:d}, {:s}", player->getGUID(), pid, runningId, item->getID(), item->getSubType(), db.escapeBlob(attributes, attributesSize)))) {
			return false;
		}

	}

	while (!queue.empty()) {
		const ContainerBlock& cb = queue.front();
		Container* container = cb.first;
		int32_t parentId = cb.second;
		queue.pop_front();

		for (Item* item : container->getItemList()) {
			++runningId;

			Container* subContainer = item->getContainer();
			if (subContainer) {
				auto it = openContainers.find(subContainer);
				if (it == openContainers.end()) {
					subContainer->resetAutoOpen();
				} else {
					subContainer->setAutoOpen(it->second);
				}
				queue.emplace_back(subContainer, runningId);
			}

			propWriteStream.clear();
			item->serializeAttr(propWriteStream);

			size_t attributesSize;
			const char* attributes = propWriteStream.getStream(attributesSize);

			if (!query_insert.addRow(fmt::format("{:d}, {:d}, {:d}, {:d}, {:d}, {:s}", player->getGUID(), parentId, runningId, item->getID(), item->getSubType(), db.escapeBlob(attributes, attributesSize)))) {
				return false;
			}
		}
	}
	return query_insert.execute();
}

bool IOLoginData::addRewardItems(uint32_t playerId, const ItemBlockList& itemList, DBInsert& query_insert, PropWriteStream& propWriteStream)
{
    using ContainerBlock = std::pair<Container*, int32_t>;
    std::list<ContainerBlock> queue;
    Database& db = Database::getInstance();
    DBResult_ptr result = db.storeQuery(fmt::format("SELECT MAX(pid) as max_pid FROM `player_rewarditems` WHERE `player_id` = {:d}", playerId));
    int32_t runningId = 1;
    int32_t pidCounter = 1;
    if (result) {
        int32_t maxPid = result->getNumber<int32_t>("max_pid");
        if (maxPid > 0) {
            pidCounter = maxPid + 1;
        }
    }
    int32_t parentPid = pidCounter;
    for (const auto& it : itemList) {
        Item* item = it.second;
        propWriteStream.clear();
        item->serializeAttr(propWriteStream);

        size_t streamSize;
        if (!query_insert.addRow(fmt::format("{:d}, {:d}, {:d}, {:d}, {:d}, {:s}",
            playerId, parentPid, runningId, item->getID(), item->getSubType(), db.escapeString(propWriteStream.getStream(streamSize))))) {
            return false;
        }

        if (Container* container = item->getContainer()) {
            queue.emplace_back(container, runningId);
        }
        ++runningId;
    }
    while (!queue.empty()) {
        const ContainerBlock& cb = queue.front();
        Container* container = cb.first;
        int32_t parentId = cb.second;
        queue.pop_front();
        for (Item* item : container->getItemList()) {
            propWriteStream.clear();
            item->serializeAttr(propWriteStream);

            size_t streamSize;
            if (!query_insert.addRow(fmt::format("{:d}, {:d}, {:d}, {:d}, {:d}, {:s}",
                playerId, parentId, runningId, item->getID(), item->getSubType(), db.escapeString(propWriteStream.getStream(streamSize))))) {
                return false;
            }
            Container* subContainer = item->getContainer();
            if (subContainer) {
                queue.emplace_back(subContainer, runningId);
            }
            ++runningId;
        }
    }
    return query_insert.execute();
}

bool IOLoginData::savePlayer(Player* player)
{
	if (player->getHealth() <= 0) {
		player->changeHealth(1);
	}

	Database& db = Database::getInstance();

	DBResult_ptr result = db.storeQuery(fmt::format("SELECT `save` FROM `players` WHERE `id` = {:d}", player->getGUID()));
	if (!result) {
		return false;
	}

	if (result->getNumber<uint16_t>("save") == 0) {
		return db.executeQuery(fmt::format("UPDATE `players` SET `lastlogin` = {:d}, `lastip` = {:d} WHERE `id` = {:d}", player->lastLoginSaved, player->lastIP, player->getGUID()));
	}

	//serialize conditions
	PropWriteStream propWriteStream;
	for (Condition* condition : player->conditions) {
		if (condition->isPersistent()) {
			condition->serialize(propWriteStream);
			propWriteStream.write<uint8_t>(CONDITIONATTR_END);
		}
	}

	size_t conditionsSize;
	const char* conditions = propWriteStream.getStream(conditionsSize);

	//serialize loot list
	PropWriteStream propWriteStreamLootList;
	propWriteStreamLootList.write<uint16_t>(player->autoLootItems.size());
	for (auto& itItem : player->autoLootItems)
	{
		propWriteStreamLootList.write<uint16_t>(itItem);
	}

	propWriteStreamLootList.write<uint16_t>(0);
	size_t autolootSize;
	const char* autoloot = propWriteStreamLootList.getStream(autolootSize);

	//serialize battlepass
	PropWriteStream propWriteStreamBattlepass;
	propWriteStreamBattlepass.write<uint32_t>(player->battlepass->getExperience());
	propWriteStreamBattlepass.write<uint16_t>(player->battlepass->getLevel());
	propWriteStreamBattlepass.write<bool>(player->battlepass->hasPremium());

	BattlePassPlayerDataMap battlepassData = player->battlepass->getBattlepass();
	propWriteStreamBattlepass.write<uint8_t>(battlepassData.size());

	for (auto& itBattlepassType : battlepassData) {
		propWriteStreamBattlepass.write<uint8_t>(itBattlepassType.first); // Battlepass type (daily, weekly, special)
		propWriteStreamBattlepass.write<uint8_t>(itBattlepassType.second.size());
		for (auto& itBattlepass : itBattlepassType.second) {
			propWriteStreamBattlepass.write<uint16_t>(itBattlepass.id); // Battlepass id (type of the quest, kill a monster, get an item etc...)
			propWriteStreamBattlepass.write<uint64_t>(itBattlepass.cooldown);
			propWriteStreamBattlepass.write<uint32_t>(itBattlepass.amount);
			propWriteStreamBattlepass.write<uint8_t>(itBattlepass.shuffled ? 1 : 0);
			if (itBattlepass.data->value.has_value())
			{
				const auto& valueType = itBattlepass.data->value.type();
				if (valueType == typeid(uint16_t)) {
					propWriteStreamBattlepass.write<uint8_t>(ItemAttributesStruct::Type::INTEGER);
					propWriteStreamBattlepass.write<uint16_t>(std::any_cast<uint16_t>(itBattlepass.data->value));
				} else if (valueType == typeid(std::string)) {
					propWriteStreamBattlepass.write<uint8_t>(ItemAttributesStruct::Type::STRING);
					propWriteStreamBattlepass.writeString(std::any_cast<std::string>(itBattlepass.data->value));
				}
			} else {
				propWriteStreamBattlepass.write<uint8_t>(0);
			}
		}
	}

	size_t battlepassSize;
	const char* battlepass = propWriteStreamBattlepass.getStream(battlepassSize);


	//First, an UPDATE query to write the player itself
	std::ostringstream query;
	query << "UPDATE `players` SET ";
	query << "`level` = " << player->level << ',';
	query << "`group_id` = " << player->group->id << ',';
	query << "`vocation` = " << player->getVocationId() << ',';
	query << "`health` = " << player->health << ',';
	query << "`healthmax` = " << player->healthMax << ',';
	query << "`experience` = " << player->experience << ',';
	query << "`lookbody` = " << static_cast<uint32_t>(player->defaultOutfit.lookBody) << ',';
	query << "`lookfeet` = " << static_cast<uint32_t>(player->defaultOutfit.lookFeet) << ',';
	query << "`lookhead` = " << static_cast<uint32_t>(player->defaultOutfit.lookHead) << ',';
	query << "`looklegs` = " << static_cast<uint32_t>(player->defaultOutfit.lookLegs) << ',';
	query << "`lookmounthead` = " << static_cast<uint32_t>(player->defaultOutfit.lookMountHead) << ',';
	query << "`lookmountbody` = " << static_cast<uint32_t>(player->defaultOutfit.lookMountBody) << ',';
	query << "`lookmountlegs` = " << static_cast<uint32_t>(player->defaultOutfit.lookMountLegs) << ',';
	query << "`lookmountfeet` = " << static_cast<uint32_t>(player->defaultOutfit.lookMountFeet) << ',';
	query << "`looktype` = " << player->defaultOutfit.lookType << ',';
	query << "`lookaddons` = " << static_cast<uint32_t>(player->defaultOutfit.lookAddons) << ',';
	query << "`maglevel` = " << player->magLevel << ',';
	query << "`mana` = " << player->mana << ',';
	query << "`manamax` = " << player->manaMax << ',';
	query << "`manaspent` = " << player->manaSpent << ',';
	query << "`soul` = " << static_cast<uint16_t>(player->soul) << ',';
	query << "`town_id` = " << player->town->getID() << ',';

	const Position& loginPosition = player->getLoginPosition();
	query << "`posx` = " << loginPosition.getX() << ',';
	query << "`posy` = " << loginPosition.getY() << ',';
	query << "`posz` = " << loginPosition.getZ() << ',';

	query << "`cap` = " << (player->capacity / 100) << ',';
	query << "`sex` = " << static_cast<uint16_t>(player->sex) << ',';

	if (player->lastLoginSaved != 0) {
		query << "`lastlogin` = " << player->lastLoginSaved << ',';
	}

	if (player->lastIP != 0) {
		query << "`lastip` = " << player->lastIP << ',';
	}

	query << "`conditions` = " << db.escapeBlob(conditions, conditionsSize) << ',';
	query << "`battlepass` = " << db.escapeBlob(battlepass, battlepassSize) << ',';
	query << "`autoloot` = " << db.escapeBlob(autoloot, autolootSize) << ',';

	if (g_game.getWorldType() != WORLD_TYPE_PVP_ENFORCED) {
		int64_t skullTime = 0;

		if (player->skullTicks > 0) {
			skullTime = time(nullptr) + player->skullTicks;
		}
		query << "`skulltime` = " << skullTime << ',';

		Skulls_t skull = SKULL_NONE;
		if (player->skull == SKULL_RED) {
			skull = SKULL_RED;
		} else if (player->skull == SKULL_BLACK) {
			skull = SKULL_BLACK;
		}
		query << "`skull` = " << static_cast<int64_t>(skull) << ',';
	}

	query << "`lastlogout` = " << player->getLastLogout() << ',';
	query << "`balance` = " << player->bankBalance << ',';
	query << "`offlinetraining_time` = " << player->getOfflineTrainingTime() / 1000 << ',';
	query << "`offlinetraining_skill` = " << player->getOfflineTrainingSkill() << ',';
	query << "`stamina` = " << player->getStaminaMinutes() << ',';

	query << "`skill_fist` = " << player->skills[SKILL_FIST].level << ',';
	query << "`skill_fist_tries` = " << player->skills[SKILL_FIST].tries << ',';
	query << "`skill_club` = " << player->skills[SKILL_CLUB].level << ',';
	query << "`skill_club_tries` = " << player->skills[SKILL_CLUB].tries << ',';
	query << "`skill_sword` = " << player->skills[SKILL_SWORD].level << ',';
	query << "`skill_sword_tries` = " << player->skills[SKILL_SWORD].tries << ',';
	query << "`skill_axe` = " << player->skills[SKILL_AXE].level << ',';
	query << "`skill_axe_tries` = " << player->skills[SKILL_AXE].tries << ',';
	query << "`skill_dist` = " << player->skills[SKILL_DISTANCE].level << ',';
	query << "`skill_dist_tries` = " << player->skills[SKILL_DISTANCE].tries << ',';
	query << "`skill_shielding` = " << player->skills[SKILL_SHIELD].level << ',';
	query << "`skill_shielding_tries` = " << player->skills[SKILL_SHIELD].tries << ',';
	query << "`skill_fishing` = " << player->skills[SKILL_FISHING].level << ',';
	query << "`skill_fishing_tries` = " << player->skills[SKILL_FISHING].tries << ',';
	query << "`skill_crafting` = " << player->skills[SKILL_CRAFTING].level << ',';
	query << "`skill_crafting_tries` = " << player->skills[SKILL_CRAFTING].tries << ',';
	query << "`skill_woodcutting` = " << player->skills[SKILL_WOODCUTTING].level << ',';
	query << "`skill_woodcutting_tries` = " << player->skills[SKILL_WOODCUTTING].tries << ',';
	query << "`skill_mining` = " << player->skills[SKILL_MINING].level << ',';
	query << "`skill_mining_tries` = " << player->skills[SKILL_MINING].tries << ',';
	query << "`skill_herbalist` = " << player->skills[SKILL_HERBALIST].level << ',';
	query << "`skill_herbalist_tries` = " << player->skills[SKILL_HERBALIST].tries << ',';
	query << "`direction` = " << static_cast<int16_t> (player->getDirection()) << ',';
	query << "`stat_str` = " << static_cast<int16_t>(player->charStats[CHARSTAT_STRENGTH]) << ',';
	query << "`stat_int` = " << static_cast<int16_t>(player->charStats[CHARSTAT_INTELLIGENCE]) << ',';
	query << "`stat_dex` = " << static_cast<int16_t>(player->charStats[CHARSTAT_DEXTERITY]) << ',';
	query << "`stat_vit` = " << static_cast<int16_t>(player->charStats[CHARSTAT_VITALITY]) << ',';
	query << "`stat_spr` = " << static_cast<int16_t>(player->charStats[CHARSTAT_SPIRIT]) << ',';
	query << "`stat_wis` = " << static_cast<int16_t>(player->charStats[CHARSTAT_WISDOM]) << ',';
	query << "`skill_armorsmith` = " << player->skills[SKILL_ARMORSMITH].level << ',';
	query << "`skill_armorsmith_tries` = " << player->skills[SKILL_ARMORSMITH].tries << ',';
	query << "`skill_weaponsmith` = " << player->skills[SKILL_WEAPONSMITH].level << ',';
	query << "`skill_weaponsmith_tries` = " << player->skills[SKILL_WEAPONSMITH].tries << ',';
	query << "`skill_jewelsmith` = " << player->skills[SKILL_JEWELSMITH].level << ',';
	query << "`skill_jewelsmith_tries` = " << player->skills[SKILL_JEWELSMITH].tries << ',';

	if (!player->isOffline()) {
		query << "`onlinetime` = `onlinetime` + " << (time(nullptr) - player->lastLoginSaved) << ',';
	}
	query << "`blessings` = " << player->blessings.to_ulong();
	query << " WHERE `id` = " << player->getGUID();

	DBTransaction transaction;
	if (!transaction.begin()) {
		return false;
	}

	if (!db.executeQuery(query.str())) {
		return false;
	}

	// learned spells
	if (!db.executeQuery(fmt::format("DELETE FROM `player_spells` WHERE `player_id` = {:d}", player->getGUID()))) {
		return false;
	}

	DBInsert spellsQuery("INSERT INTO `player_spells` (`player_id`, `name` ) VALUES ");
	for (const std::string& spellName : player->learnedInstantSpellList) {
		if (!spellsQuery.addRow(fmt::format("{:d}, {:s}", player->getGUID(), db.escapeString(spellName)))) {
			return false;
		}
	}

	if (!spellsQuery.execute()) {
		return false;
	}

	//item saving
	std::map<Container*, int> openContainers;
	for (auto container : player->getOpenContainers()) {
		if (!container.second.container) continue;
		openContainers[container.second.container] = container.first;
	}
	if (!db.executeQuery(fmt::format("DELETE FROM `player_items` WHERE `player_id` = {:d}", player->getGUID()))) {
		return false;
	}

	DBInsert itemsQuery("INSERT INTO `player_items` (`player_id`, `pid`, `sid`, `itemtype`, `count`, `attributes`) VALUES ");

	ItemBlockList itemList;
	for (int32_t slotId = CONST_SLOT_FIRST; slotId <= CONST_SLOT_LAST; ++slotId) {
		Item* item = player->inventory[slotId];
		if (item) {
			itemList.emplace_back(slotId, item);
		}
	}

	if (!saveItems(player, itemList, itemsQuery, propWriteStream, openContainers)) {
		return false;
	}

	if (player->lastDepotId != -1) {
		//save depot items
		if (!db.executeQuery(fmt::format("DELETE FROM `player_depotitems` WHERE `player_id` = {:d}", player->getGUID()))) {
			return false;
		}

		DBInsert depotQuery("INSERT INTO `player_depotitems` (`player_id`, `pid`, `sid`, `itemtype`, `count`, `attributes`) VALUES ");
		itemList.clear();

		for (const auto& it : player->depotChests) {
			for (Item* item : it.second->getItemList()) {
				itemList.emplace_back(it.first, item);
			}
		}

		if (!saveItems(player, itemList, depotQuery, propWriteStream, openContainers)) {
			return false;
		}
	}

	// save reward items
	if (!db.executeQuery(fmt::format("DELETE FROM `player_rewarditems` WHERE `player_id` = {:d}", player->getGUID()))) {
		return false;
	}

	DBInsert rewardQuery("INSERT INTO `player_rewarditems` (`player_id`, `pid`, `sid`, `itemtype`, `count`, `attributes`) VALUES ");
	itemList.clear();

	int32_t pidCounter = 1;

	for (Item* item : player->getRewardChest().getItemList()) {
		if (Container* container = item->getContainer()) {
			int32_t currentPid = pidCounter++;
			for (Item* subItem : container->getItemList()) {
				itemList.emplace_back(currentPid, subItem);
			}
		}
		else {
			itemList.emplace_back(0, item);
		}
	}

	if (!saveItems(player, itemList, rewardQuery, propWriteStream, openContainers)) {
		return false;
	}

	//save inbox items
	if (!db.executeQuery(fmt::format("DELETE FROM `player_inboxitems` WHERE `player_id` = {:d}", player->getGUID()))) {
		return false;
	}

	DBInsert inboxQuery("INSERT INTO `player_inboxitems` (`player_id`, `pid`, `sid`, `itemtype`, `count`, `attributes`) VALUES ");
	itemList.clear();

	for (Item* item : player->getInbox()->getItemList()) {
		itemList.emplace_back(0, item);
	}

	if (Container* caravanContainer = player->getCaravanContainer()) {
		itemList.emplace_back(0, caravanContainer);
	}

	if (!saveItems(player, itemList, inboxQuery, propWriteStream, openContainers)) {
		return false;
	}

	//save store inbox items
	if (!db.executeQuery(fmt::format("DELETE FROM `player_storeinboxitems` WHERE `player_id` = {:d}", player->getGUID()))) {
		return false;
	}

	DBInsert storeInboxQuery("INSERT INTO `player_storeinboxitems` (`player_id`, `pid`, `sid`, `itemtype`, `count`, `attributes`) VALUES ");
	itemList.clear();

	for (Item* item : player->getStoreInbox()->getItemList()) {
		itemList.emplace_back(0, item);
	}

	if (!saveItems(player, itemList, storeInboxQuery, propWriteStream, openContainers)) {
		return false;
	}

	if (!db.executeQuery(fmt::format("DELETE FROM `player_storage` WHERE `player_id` = {:d}", player->getGUID()))) {
		return false;
	}

	DBInsert storageQuery("INSERT INTO `player_storage` (`player_id`, `key`, `value`) VALUES ");
	player->genReservedStorageRange();

	for (const auto& it : player->storageMap) {
		if (!storageQuery.addRow(fmt::format("{:d}, {:d}, {:d}", player->getGUID(), it.first, it.second))) {
			return false;
		}
	}

	if (!storageQuery.execute()) {
		return false;
	}

	if (!db.executeQuery(fmt::format("DELETE FROM `player_prey` WHERE `player_id` = {:d}", player->getGUID()))) {
		return false;
	}

	DBInsert preyQuery("INSERT INTO `player_prey` (`player_id`, `slot`, `monster_name`, `look_type`, `look_type_ex`, `look_head`, `look_body`, `look_legs`, `look_feet`, `look_addons`, `look_mount`, `look_wings`, `look_aura`, `look_shader`, `bonus_type`, `bonus_value`, `bonus_grade`, `expires_at`, `free_reroll_at`, `lock_type`) VALUES ");
	for (uint8_t slotId = 0; slotId < PREY_SLOT_COUNT; ++slotId) {
		const PreySlot& preySlot = player->getPreySlot(slotId);
		if (!preySlot.active || preySlot.monsterName.empty() || preySlot.expiresAt <= std::time(nullptr)) {
			continue;
		}

		if (!preyQuery.addRow(fmt::format(
			"{:d}, {:d}, {:s}, {:d}, {:d}, {:d}, {:d}, {:d}, {:d}, {:d}, {:d}, {:d}, {:d}, {:d}, {:d}, {:d}, {:d}, {:d}, {:d}, {:d}",
			player->getGUID(), slotId, db.escapeString(preySlot.monsterName),
			preySlot.outfit.lookType, preySlot.outfit.lookTypeEx,
			preySlot.outfit.lookHead, preySlot.outfit.lookBody, preySlot.outfit.lookLegs, preySlot.outfit.lookFeet, preySlot.outfit.lookAddons,
			preySlot.outfit.lookMount, preySlot.outfit.lookWings, preySlot.outfit.lookAura, preySlot.outfit.lookShader,
			preySlot.bonusType, preySlot.bonusValue, preySlot.bonusGrade, preySlot.expiresAt, preySlot.freeRerollAt, preySlot.lockType))) {
			return false;
		}
	}

	if (!preyQuery.execute()) {
		return false;
	}

	if (!db.executeQuery(fmt::format(
		"INSERT INTO `player_prey_resources` (`player_id`, `unlocked_slots`, `hunting_task_unlocked_slots`, `wildcards`, `updated_at`) VALUES ({:d}, {:d}, {:d}, {:d}, {:d}) "
		"ON DUPLICATE KEY UPDATE `unlocked_slots` = VALUES(`unlocked_slots`), `hunting_task_unlocked_slots` = VALUES(`hunting_task_unlocked_slots`), `wildcards` = VALUES(`wildcards`), `updated_at` = VALUES(`updated_at`)",
		player->getGUID(), player->getPreyUnlockedSlots(), player->getHuntingTaskUnlockedSlots(), player->getPreyWildcards(), std::time(nullptr)))) {
		return false;
	}

	//End the transaction
	return transaction.commit();
}

std::string IOLoginData::getNameByGuid(uint32_t guid)
{
	DBResult_ptr result = Database::getInstance().storeQuery(fmt::format("SELECT `name` FROM `players` WHERE `id` = {:d}", guid));
	if (!result) {
		return std::string();
	}
	return result->getString("name");
}

uint32_t IOLoginData::getGuidByName(const std::string& name)
{
	Database& db = Database::getInstance();

	DBResult_ptr result = db.storeQuery(fmt::format("SELECT `id` FROM `players` WHERE `name` = {:s}", db.escapeString(name)));
	if (!result) {
		return 0;
	}
	return result->getNumber<uint32_t>("id");
}

bool IOLoginData::getGuidByNameEx(uint32_t& guid, bool& specialVip, std::string& name)
{
	Database& db = Database::getInstance();

	DBResult_ptr result = db.storeQuery(fmt::format("SELECT `name`, `id`, `group_id`, `account_id` FROM `players` WHERE `name` = {:s}", db.escapeString(name)));
	if (!result) {
		return false;
	}

	name = result->getString("name");
	guid = result->getNumber<uint32_t>("id");
	Group* group = g_game.groups.getGroup(result->getNumber<uint16_t>("group_id"));

	uint64_t flags;
	if (group) {
		flags = group->flags;
	} else {
		flags = 0;
	}

	specialVip = (flags & PlayerFlag_SpecialVIP) != 0;
	return true;
}

bool IOLoginData::formatPlayerName(std::string& name)
{
	Database& db = Database::getInstance();

	DBResult_ptr result = db.storeQuery(fmt::format("SELECT `name` FROM `players` WHERE `name` = {:s}", db.escapeString(name)));
	if (!result) {
		return false;
	}

	name = result->getString("name");
	return true;
}

void IOLoginData::loadItems(ItemMap& itemMap, DBResult_ptr result)
{
	do {
		uint32_t sid = result->getNumber<uint32_t>("sid");
		uint32_t pid = result->getNumber<uint32_t>("pid");
		uint16_t type = result->getNumber<uint16_t>("itemtype");
		uint16_t count = result->getNumber<uint16_t>("count");

		unsigned long attrSize;
		const char* attr = result->getStream("attributes", attrSize);

		PropStream propStream;
		propStream.init(attr, attrSize);

		Item* item = Item::CreateItem(type, count);
		if (item) {
			if (!item->unserializeAttr(propStream)) {
				std::cout << "WARNING: Serialize error in IOLoginData::loadItems" << std::endl;
			}

			std::pair<Item*, uint32_t> pair(item, pid);
			itemMap[sid] = pair;
		}
	} while (result->next());
}

void IOLoginData::increaseBankBalance(uint32_t guid, uint64_t bankBalance)
{
	Database::getInstance().executeQuery(fmt::format("UPDATE `players` SET `balance` = `balance` + {:d} WHERE `id` = {:d}", bankBalance, guid));
}

bool IOLoginData::hasBiddedOnHouse(uint32_t guid)
{
	Database& db = Database::getInstance();
	return db.storeQuery(fmt::format("SELECT `id` FROM `houses` WHERE `highest_bidder` = {:d} LIMIT 1", guid)).get() != nullptr;
}

std::forward_list<VIPEntry> IOLoginData::getVIPEntries(uint32_t accountId)
{
	std::forward_list<VIPEntry> entries;

	DBResult_ptr result = Database::getInstance().storeQuery(fmt::format("SELECT `player_id`, (SELECT `name` FROM `players` WHERE `id` = `player_id`) AS `name`, `description`, `icon`, `notify` FROM `account_viplist` WHERE `account_id` = {:d}", accountId));
	if (result) {
		do {
			entries.emplace_front(
				result->getNumber<uint32_t>("player_id"),
				result->getString("name"),
				result->getString("description"),
				result->getNumber<uint32_t>("icon"),
				result->getNumber<uint16_t>("notify") != 0
			);
		} while (result->next());
	}
	return entries;
}

void IOLoginData::addVIPEntry(uint32_t accountId, uint32_t guid, const std::string& description, uint32_t icon, bool notify)
{
	Database& db = Database::getInstance();
	db.executeQuery(fmt::format("INSERT INTO `account_viplist` (`account_id`, `player_id`, `description`, `icon`, `notify`) VALUES ({:d}, {:d}, {:s}, {:d}, {:d})", accountId, guid, db.escapeString(description), icon, notify));
}

void IOLoginData::editVIPEntry(uint32_t accountId, uint32_t guid, const std::string& description, uint32_t icon, bool notify)
{
	Database& db = Database::getInstance();
	db.executeQuery(fmt::format("UPDATE `account_viplist` SET `description` = {:s}, `icon` = {:d}, `notify` = {:d} WHERE `account_id` = {:d} AND `player_id` = {:d}", db.escapeString(description), icon, notify, accountId, guid));
}

void IOLoginData::removeVIPEntry(uint32_t accountId, uint32_t guid)
{
	Database::getInstance().executeQuery(fmt::format("DELETE FROM `account_viplist` WHERE `account_id` = {:d} AND `player_id` = {:d}", accountId, guid));
}

void IOLoginData::updatePremiumTime(uint32_t accountId, time_t endTime)
{
	Database::getInstance().executeQuery(fmt::format("UPDATE `accounts` SET `premium_ends_at` = {:d} WHERE `id` = {:d}", endTime, accountId));
}

bool IOLoginData::playerMail(std::string name, uint32_t townId, Item* item)
{
	Player* player = nullptr;
	if (g_game.getPlayerByNameWildcard(name, player) != RETURNVALUE_NOERROR) {
		return false;
	}

	if (townId == 0) {
		townId = player->getTown()->getID();
	}

	DepotChest* depot = player->getDepotChest(townId, true);
	if (depot) {
		Container* container = depot->getContainer();
		if (container) {
			ReturnValue ret = g_game.internalMoveItem(item->getParent(), container, INDEX_WHEREEVER, item, item->getItemCount(), nullptr);
			if (ret != RETURNVALUE_NOERROR) {
				if (item->getID() == ITEM_PARCEL) {
					g_game.transformItem(item, item->getID() + 1);
				}
			}
		}
	}

	return true;
}
