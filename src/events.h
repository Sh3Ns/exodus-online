// Copyright 2022 The Forgotten Server Authors. All rights reserved.
// Use of this source code is governed by the GPL-2.0 License that can be found in the LICENSE file.

#ifndef FS_EVENTS_H_BD444CC0EE167E5777E4C90C766B36DC
#define FS_EVENTS_H_BD444CC0EE167E5777E4C90C766B36DC

#include "luascript.h"
#include "const.h"
#include "creature.h"
#include "dungeon.h"

class Party;
class ItemType;
class Tile;

enum class EventInfoId {
	CREATURE_ONHEAR
};

class Events
{
	struct EventsInfo {
		// Creature
		int32_t creatureOnChangeOutfit = -1;
		int32_t creatureOnAreaCombat = -1;
		int32_t creatureOnTargetCombat = -1;
		int32_t creatureOnHear = -1;

		// Party
		int32_t partyOnJoin = -1;
		int32_t partyOnLeave = -1;
		int32_t partyOnDisband = -1;
		int32_t partyOnShareExperience = -1;
		int32_t partyOnLeaderPass = -1;

		// Player
		int32_t playerOnBrowseField = -1;
		int32_t playerOnLook = -1;
		int32_t playerOnLookInBattleList = -1;
		int32_t playerOnLookInTrade = -1;
		int32_t playerOnLookInShop = -1;
		int32_t playerOnMoveItem = -1;
		int32_t playerOnItemMoved = -1;
		int32_t playerOnMoveCreature = -1;
		int32_t playerOnReportRuleViolation = -1;
		int32_t playerOnReportBug = -1;
		int32_t playerOnTurn = -1;
		int32_t playerOnTradeRequest = -1;
		int32_t playerOnTradeAccept = -1;
		int32_t playerOnTradeCompleted = -1;
		int32_t playerOnGainExperience = -1;
		int32_t playerOnLoseExperience = -1;
		int32_t playerOnGainSkillTries = -1;
		int32_t playerOnWrapItem = -1;
		int32_t playerOnInventoryUpdate = -1;
		int32_t playerOnSpellCast = -1;
		int32_t playerOnSpellCost = -1;
		int32_t playerOnSpellPreCast = -1;
		int32_t playerOnSpellCooldown = -1;
		int32_t playerOnQueueLeave = -1;

		// Dungeon
		int32_t dungeonOnQueue = -1;
		int32_t dungeonOnPrepare = -1;
		int32_t dungeonOnStart = -1;
		int32_t dungeonOnSuccess = -1;
		int32_t dungeonOnFail = -1;
		int32_t dungeonOnPlayerLeave = -1;
		int32_t dungeonOnMonstersCount = -1;

		// Monster
		int32_t monsterOnDropLoot = -1;
		int32_t monsterOnSpawn = -1;
	};

	public:
		Events();

		bool load();

		// Creature
		bool eventCreatureOnChangeOutfit(Creature* creature, const Outfit_t& outfit);
		ReturnValue eventCreatureOnAreaCombat(Creature* creature, Tile* tile, bool aggressive);
		ReturnValue eventCreatureOnTargetCombat(Creature* creature, Creature* target);
		void eventCreatureOnHear(Creature* creature, Creature* speaker, const std::string& words, SpeakClasses type);

		// Party
		bool eventPartyOnJoin(Party* party, Player* player);
		bool eventPartyOnLeave(Party* party, Player* player);
		bool eventPartyOnDisband(Party* party);
		void eventPartyOnShareExperience(Party* party, uint64_t& exp);
		bool eventPartyOnLeaderPass(Party* party, Player* oldLeader, Player* newLeader);

		// Player
		bool eventPlayerOnBrowseField(Player* player, const Position& position);
		void eventPlayerOnLook(Player* player, const Position& position, Thing* thing, uint8_t stackpos, int32_t lookDistance);
		void eventPlayerOnLookInBattleList(Player* player, Creature* creature, int32_t lookDistance);
		void eventPlayerOnLookInTrade(Player* player, Player* partner, Item* item, int32_t lookDistance);
		bool eventPlayerOnLookInShop(Player* player, const ItemType* itemType, uint8_t count, const std::string& description);
		ReturnValue eventPlayerOnMoveItem(Player* player, Item* item, uint16_t count, const Position& fromPosition, const Position& toPosition, Cylinder* fromCylinder, Cylinder* toCylinder);
		void eventPlayerOnItemMoved(Player* player, Item* item, uint16_t count, const Position& fromPosition, const Position& toPosition, Cylinder* fromCylinder, Cylinder* toCylinder);
		bool eventPlayerOnMoveCreature(Player* player, Creature* creature, const Position& fromPosition, const Position& toPosition);
		void eventPlayerOnReportRuleViolation(Player* player, const std::string& targetName, uint8_t reportType, uint8_t reportReason, const std::string& comment, const std::string& translation);
		bool eventPlayerOnReportBug(Player* player, const std::string& message, const Position& position, uint8_t category);
		bool eventPlayerOnTurn(Player* player, Direction direction);
		bool eventPlayerOnTradeRequest(Player* player, Player* target, Item* item);
		bool eventPlayerOnTradeAccept(Player* player, Player* target, Item* item, Item* targetItem);
		void eventPlayerOnTradeCompleted(Player* player, Player* target, Item* item, Item* targetItem, bool isSuccess);
		void eventPlayerOnGainExperience(Player* player, Creature* source, uint64_t& exp, uint64_t rawExp);
		void eventPlayerOnLoseExperience(Player* player, uint64_t& exp);
		void eventPlayerOnGainSkillTries(Player* player, skills_t skill, uint64_t& tries);
		void eventPlayerOnWrapItem(Player* player, Item* item);
		void eventPlayerOnInventoryUpdate(Player* player, Item* item, slots_t slot, bool equip);
		void eventPlayerOnSpellCast(Player* player, const std::string& spellName, const std::string& spellGroup, bool aggressive, uint32_t manaCost);
		uint32_t eventPlayerOnSpellCost(Player* player, const std::string& spellName, const std::string& spellGroup, bool aggressive, uint32_t manaCost, uint32_t missingMana);
		void eventPlayerOnSpellPreCast(Player* player, const std::string& spellName, const std::string& spellGroup, bool aggressive, uint32_t manaCost, uint32_t healthCost);
		uint32_t eventPlayerOnSpellCooldown(Player* player, const std::string& spellName, const std::string& spellGroup, bool aggressive, const std::string& cooldownType, uint32_t currentCooldown);
		void eventPlayerOnQueueLeave(Player* player, DungeonQueue* queue);
		// Monster
		void eventMonsterOnDropLoot(Monster* monster, Container* corpse);
		bool eventMonsterOnSpawn(Monster* monster, const Position& position, bool startup, bool artificial);

		// Dungeon
		void eventDungeonOnQueue(Dungeon* dungeon);
		void eventDungeonOnPrepare(Dungeon* dungeon, DungeonInstance* instance, Player* player);
		void eventDungeonOnStart(Dungeon* dungeon, DungeonInstance* instance, Player* player);
		void eventDungeonOnSuccess(Dungeon* dungeon, DungeonInstance* instance);
		void eventDungeonOnFail(Dungeon* dungeon, DungeonInstance* instance);
		void eventDungeonOnPlayerLeave(Dungeon* dungeon, DungeonInstance* instance, Player* player);
		void eventDungeonOnMonstersCount(DungeonInstance* instance, uint16_t monsters);
		int32_t getScriptId(EventInfoId eventInfoId) {
			switch (eventInfoId)
			{
			case EventInfoId::CREATURE_ONHEAR:
				return info.creatureOnHear;
			default:
				return -1;
			}
		};

	private:
		LuaScriptInterface scriptInterface;
		EventsInfo info;
};

#endif
