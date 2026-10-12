/**
 * The Forgotten Server - a free and open-source MMORPG server emulator
 * Copyright (C) 2021  Arkadiusz <lach@includespark.eu>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#include "otpch.h"

#include "dungeon.h"
#include "player.h"
#include "game.h"
#include "events.h"
#include "monster.h"
#include "scheduler.h"

extern Events* g_events;
extern Game g_game;

static uint16_t lastInstanceId = 0;

Dungeon::Dungeon()
{
    queue = new DungeonQueue();
    queue->setDungeon(this);
}

bool Dungeon::joinQueue(Player* player, uint8_t difficulty)
{
    if (!canJoin(player)) {
        player->sendFYIBox("Can't join dungeon, you don't meet requirements!");
        return false;
    }

    uint8_t queuePosition = queue->addPlayer(player);
    size_t queueAmount = queue->getPlayersNumber();

    Party* party = player->getParty();
    if (require.party.max >= 2 && party) {
        if (party) {
            Player* leader = party->getLeader();
            PlayerVector members = party->getMembers();
            for (Player* member : members) {
                if (!canJoin(member, true)) {
                    std::ostringstream text;
                    text << "Can't join dungeon, " << member->getName() << " doesn't meet requirements!";
                    player->sendFYIBox(text.str());
                    queue->removePlayer(player);
                    return false;
                }
            }
			
            bool sent = false;
            for (Player* member : members) {
                if (queueAmount == 1 && queuePosition == 1 && getFreeInstance()) {
                    std::ostringstream text;
                    text << "Party leader joined " << getTitle() << " dungeon, you will be teleported in 3 seconds.";
                    member->sendFYIBox(text.str());
                    member->setDungeon(this);
                    member->setDungeonDifficulty(difficulty);
                    if (!sent) {
                        sent = true;
                        text.str("");
                        text << "Joined " << getTitle() << " dungeon, you will be teleported in 3 seconds.";
                        leader->sendFYIBox(text.str());
                    }
                }
                else {
                    std::ostringstream text;
                    text << "Party leader joined " << getTitle() << " dungeon queue! Position in queue: " << signed(queuePosition);
                    member->sendFYIBox(text.str());
                    if (!sent) {
                        sent = true;
                        text.str("");
                        text << "Joined " << getTitle() << " dungeon queue! Position in queue: " << signed(queuePosition);
                        leader->sendFYIBox(text.str());
                    }
                }
            }
        }
    }
    else {
        std::ostringstream text;
        if (queueAmount == 1 && queuePosition == 1 && getFreeInstance()) {
            text << "Joined " << getTitle() << " dungeon, you will be teleported in 3 seconds";
            player->sendFYIBox(text.str());
        }
        else {
            text << "Joined " << getTitle() << " dungeon queue! Position in queue: " << signed(queuePosition);
            player->sendFYIBox(text.str());
        }
    }

    player->setDungeon(this);
    player->setDungeonDifficulty(difficulty);
    if (queueAmount == 1 && queuePosition == 1 && getFreeInstance()) {
        queue->popPlayer();
        prepare(player, player->getDungeonDifficulty());
    }

    g_events->eventDungeonOnQueue(this);

    return true;
}

void Dungeon::prepare(Player* player, uint8_t difficulty)
{
    if (!canJoin(player, false, true)) {
        player->sendFYIBox("Can't join dungeon, you don't meet requirements!");
        queue->onPlayerLeave(player, true);
        return;
    }

    int32_t currentTime = OTSYS_TIME() / 1000;
    Party* party = player->getParty();
    PlayerVector members;
    if (require.party.max >= 2 && party) {
        members = party->getMembers();
        if (party->getLeader() == player) {
            for (Player* member : members) {
                if (!canJoin(member, true, true)) {
                    std::ostringstream text;
                    text << "Can't join dungeon, " << member->getName() << " doesn't meet requirements!";
                    player->sendFYIBox(text.str());
                    queue->onPlayerLeave(player, true);
                    return;
                }
			}
			
            for (Player* member : members) {
                member->setDungeon(this);
                if (require.items.size() > 0) {
                    for (auto const& item : require.items) {
                        member->removeItemOfType(item.first, item.second, -1, true);
                    }
                }
                if (require.gold > 0) {
                    member->removeTotalMoney(require.gold);
                }
                if (require.time.storage > 0) {
                    member->addStorageValue(require.time.storage, currentTime + require.time.time);
                }
            }
        }
        if (require.items.size() > 0) {
            for (auto const& item : require.items) {
                player->removeItemOfType(item.first, item.second, -1, true);
            }
        }
        if (require.gold > 0) {
            player->removeTotalMoney(require.gold);
        }
        if (require.time.storage > 0) {
            player->addStorageValue(require.time.storage, currentTime + require.time.time);
        }
    }
    else {
        if (require.items.size() > 0) {
            for (auto const& item : require.items) {
                player->removeItemOfType(item.first, item.second, -1, true);
            }
        }
        if (require.gold > 0) {
            player->removeTotalMoney(require.gold);
        }
        if (require.time.storage > 0) {
            player->addStorageValue(require.time.storage, currentTime + require.time.time);
        }
    }

    DungeonInstance* instance = getFreeInstance();
    if (instance) {
        instance->build(mapFile, difficulty);
        g_events->eventDungeonOnPrepare(this, instance, player);
        g_scheduler.addEvent(createSchedulerTask(3000, std::bind(&Dungeon::start, this, player->getID(), instance, members)));
    }
    else {
        std::cout << "[Error - Dungeon:prepare] Couldn't find free instance" << std::endl;
    }
}

void Dungeon::start(uint32_t pid, DungeonInstance* instance, std::vector<Player*>& members)
{
	(void)members;

	Player* player = g_game.getPlayerByID(pid);
	if (!player) {
		sendNextPlayer();
		instance->destroy(mapFile);
		return;
	}

	Party* party = player->getParty();
	if (require.party.max >= 2 && party) {
		PlayerVector partyMembers = party->getMembers();
		if (party->getMemberCount() + 1 < require.party.min) {
			for (Player* member : partyMembers) {
				onPlayerLeave(member);
			}
			onPlayerLeave(player);
			return;
		}
		if (party->getMemberCount() + 1 > require.party.max) {
			for (Player* member : partyMembers) {
				onPlayerLeave(member);
			}
			onPlayerLeave(player);
			return;
		}
		partyMembers.push_back(player);
		instance->start(this, partyMembers);

		for (Player* member : partyMembers) {
			uint32_t mid = member->getID();
			if (timeoutEvent[mid] != 0) {
				g_scheduler.stopEvent(timeoutEvent[mid]);
				uint64_t eventId = g_scheduler.addEvent(createSchedulerTask(getDuration(), std::bind(&Dungeon::timeout, this, mid)));
				timeoutEvent[mid] = eventId;
			}
			else {
				uint64_t eventId = g_scheduler.addEvent(createSchedulerTask(getDuration(), std::bind(&Dungeon::timeout, this, mid)));
				timeoutEvent[mid] = eventId;
			}
		}
	}
    else {
        if (!player || player->isRemoved()) {
            sendNextPlayer();
            instance->destroy(mapFile);
            return;
        }

        if (!player->getDungeon()) {
            onPlayerLeave(player);
            return;
        }

        instance->start(this, player);

        if (timeoutEvent[pid] != 0) {
            g_scheduler.stopEvent(timeoutEvent[pid]);
            uint64_t eventId = g_scheduler.addEvent(createSchedulerTask(getDuration(), std::bind(&Dungeon::timeout, this, pid)));
            timeoutEvent[pid] = eventId;
        }
        else {
            uint64_t eventId = g_scheduler.addEvent(createSchedulerTask(getDuration(), std::bind(&Dungeon::timeout, this, pid)));
            timeoutEvent[pid] = eventId;
        }
    }
}

void Dungeon::timeout(uint32_t pid)
{
    Player* player = g_game.getPlayerByID(pid);
    if (!player) {
        return;
    }

    DungeonInstance* instance = getPlayerInstance(player);
    if (instance) {
        onDungeonFail(instance);
    }
    onPlayerLeave(player);
    g_game.internalTeleport(player, player->getTown()->getTemplePosition(), false);
    player->sendFYIBox("Time's up! You were teleported back to temple.");
}

void Dungeon::onPlayerLeave(Player* player)
{
    if (!player) {
        return;
    }

    player->setDungeon(nullptr);

    uint32_t pid = player->getID();
    if (timeoutEvent[pid] != 0) {
        g_scheduler.stopEvent(timeoutEvent[pid]);
        timeoutEvent[pid] = 0;
    }
    
    DungeonInstance* instance = getPlayerInstance(player);
    if (instance) {
        g_events->eventDungeonOnPlayerLeave(this, instance, player);
        g_game.internalTeleport(player, player->getTown()->getTemplePosition(), false);

        if (instance->removeRunner(player)) {
            instance->destroy(mapFile);
            sendNextPlayer();
        }
    }
}

void Dungeon::sendNextPlayer()
{
    if (queue->getPlayersNumber() > 0) {
        Player* player = queue->popPlayer();
        if (queue->getPlayersNumber() > 0) {
            queue->sendUpdate();
        }
        else {
            if (player) {
                player->sendFYIBox("Queue update, you are next! You will be teleported in 3 seconds.");
            }
        }
        if (player) {
            prepare(player, player->getDungeonDifficulty());
        }
    }
}

bool Dungeon::canJoin(Player* player, bool partyMember/*= false*/, bool prepare/*= false*/)
{
    if (!prepare) {
        Dungeon* dungeon = player->getDungeon();
        if (dungeon) {
            player->sendFYIBox("You are already in a dungeon or queue!");
            return false;
        }
    }

    if (require.gold > 0) {
        if (player->getTotalMoney() < require.gold) {
            std::ostringstream text;
            text << "You need at least " << require.gold << " to join! Missing " << require.gold - player->getTotalMoney() << " gold.";
            player->sendFYIBox(text.str());
            return false;
        }
    }

    if (require.time.storage > 0) {
        int32_t savedTime;
        int64_t currentTime = OTSYS_TIME() / 1000;
        player->getStorageValue(require.time.storage, savedTime);
        if (savedTime > currentTime) {
            std::ostringstream text;
            text << "You have to wait " << timeFromSeconds(savedTime - currentTime) << "to join!";
            player->sendFYIBox(text.str());
            return false;
        }
    }

    if (require.level > 0) {
        if (player->getLevel() < require.level) {
            std::ostringstream text;
            text << "This Dungeon requires level " << require.level << "+ to join!";
            player->sendFYIBox(text.str());
            return false;
        }
    }

    if (require.itemLevel > 0) {
        if (player->getItemLevel() < require.itemLevel) {
            std::ostringstream text;
            text << "This Dungeon requires total Item Level " << require.itemLevel << "+ to join!";
            player->sendFYIBox(text.str());
            return false;
        }
    }

    if (require.items.size() > 0) {
        for (auto const& item : require.items) {
            if (player->getItemTypeCount(item.first, -1) < item.second) {
                player->sendFYIBox("Missing required items to join dungeon!");
                return false;
            }
        }
    }

    if (!partyMember) {
        if (require.party.max >= 2) {
            Party* party = player->getParty();
            if (party) {
                size_t total = party->getMemberCount() + 1;
                if (total >= require.party.min) {
                    if (total > require.party.max) {
                        player->sendFYIBox("Party size exceeds dungeon limit!");
                        return false;
                    }
                    if (party->getLeader() != player) {
                        player->sendFYIBox("Only party leader can join dungeon queue!");
                        return false;
                    }
                }
                else {
                    std::ostringstream text;
                    text << "Dungeon requires party of " << require.party.min << "-" << require.party.max << " players!";
                    player->sendFYIBox(text.str());
                    return false;
                }
            }
            else if (require.party.min >= 2) {
                std::ostringstream text;
                text << "Dungeon requires party of " << require.party.min << "-" << require.party.max << " players!";
                player->sendFYIBox(text.str());
                return false;
            }
        }
    }

    if (require.storage.size() > 0) {
        for (auto const& storage : require.storage) {
            int32_t value;
            player->getStorageValue(storage.key, value);
            if (value < storage.value) {
                player->sendFYIBox(storage.error);
                return false;
            }
        }
    }
    
    Tile* tile = player->getTile();
    if (tile && !tile->hasFlag(TILESTATE_PROTECTIONZONE)) {
        if (player->isPzLocked() || player->hasCondition(CONDITION_INFIGHT)) {
            player->sendFYIBox("You can't be in-fight to join dungeon queue!");
            return false;
        }
    }

    return true;
}

void Dungeon::addInstance(Position position)
{
    DungeonInstance* instance = new DungeonInstance(position);
    instance->setDungeon(this);
    instance->setId(++lastInstanceId);
    instances.push_back(std::move(instance));
}

void Dungeon::onBossKill(DungeonInstance* instance)
{
    instance->setRunTime(OTSYS_TIME() - instance->getStartTime());
    onDungeonSuccess(instance);
}

void Dungeon::onStart(DungeonInstance* instance, Player* player)
{
    g_events->eventDungeonOnStart(this, instance, player);
}

void Dungeon::onDungeonSuccess(DungeonInstance* instance)
{
    g_events->eventDungeonOnSuccess(this, instance);
}

void Dungeon::onDungeonFail(DungeonInstance* instance)
{
    g_events->eventDungeonOnFail(this, instance);
}

DungeonInstance* Dungeon::getFreeInstance()
{
    for (DungeonInstance* instance : instances) {
        if (instance->isFree()) {
            return instance;
        }
    }
    return nullptr;
}

DungeonInstance* Dungeon::getPlayerInstance(Player* player)
{
    for (auto instance : instances) {
        if (instance->hasRunner(player)) {
            return instance;
        }
    }

    return nullptr;
}

uint32_t Dungeon::getEstimatedQueueTime(Player* player) const
{
    uint32_t time = 0;
    for (auto instance : instances) {
        if (instance->getRunTime() > 0) {
            time = time + instance->getRunTime();
        }
    }

    if (time == 0) {
        time = getDuration();
    }
    else {
        time /= instances.size() + 1;
    }

    int16_t playerPosition = queue->getPlayerPosition(player);
    time *= std::max<uint32_t>(1, playerPosition != -1 ? playerPosition : queue->getPlayersNumber());

    return time;
}

void Dungeon::preBuild()
{
    const std::string& path = "data/dungeons/" + mapFile + ".otbm";

    for (DungeonInstance* instance : instances) {
        const Position& position = instance->getPosition();
        g_dispatcher.addTask(createTask([path, position]() {
            try {
                g_game.loadDungeon(path, position);
            }
            catch (const std::exception& e) {
                std::cout << "[Error - Dungeon::preBuild] Failed to load map: " << e.what() << std::endl;
            }
         }));
    }
}

// Dungeon Instance
void DungeonInstance::start(Dungeon* dungeon, Player* player)
{
    addRunner(player);
    g_game.internalTeleport(player, position + dungeon->getStartPosition());
    g_game.addMagicEffect(position + dungeon->getStartPosition(), CONST_ME_TELEPORT);
    dungeon->onStart(this, player);
    startTime = OTSYS_TIME();
    dungeon->getQueue()->sendUpdate();
}

void DungeonInstance::start(Dungeon* dungeon, const std::vector<Player*>& members)
{
    for (auto player : members) {
        addRunner(player);
        g_game.internalTeleport(player, position + dungeon->getStartPosition());
        g_game.addMagicEffect(position + dungeon->getStartPosition(), CONST_ME_TELEPORT);
        dungeon->onStart(this, player);
    }
    startTime = OTSYS_TIME();
    dungeon->getQueue()->sendUpdate();
}

void DungeonInstance::build(const std::string& mapFile, uint8_t difficulty)
{
    this->difficulty = difficulty;
    free = false;
    bossSpawned = false;

    const std::string& path = "data/dungeons/" + mapFile + ".otbm";
    const Position& position = getPosition();
    g_game.respawnDungeon(path, this, position, difficulty);
}

void DungeonInstance::destroy(const std::string& mapFile)
{
	(void)mapFile;
	difficulty = 1;
	free = true;
	if (boss) {
		if (boss->isRemoved()) {
			boss->decrementReferenceCounter();
			boss = nullptr;
		}
		else {
			g_game.removeCreature(boss);
			boss = nullptr;
		}
	}

	g_game.clearDungeon(this);
}


bool DungeonInstance::spawnBoss()
{
    std::unique_ptr<Monster> monster_ptr(Monster::createMonster(dungeon->getBoss()));
    if (g_game.placeCreature(monster_ptr.get(), position + dungeon->getBossPosition(), false, true)) {
        boss = monster_ptr.release();
        boss->setDifficulty(difficulty);
        g_game.addCreatureHealth(boss);
        boss->registerCreatureEvent("DungeonBossDeath");
        boss->incrementReferenceCounter();
        bossSpawned = true;
        return true;
    }

    return false;
}

Monster* DungeonInstance::getBoss() {
    if (boss && boss->isRemoved()) {
        boss->decrementReferenceCounter();
        boss = nullptr;
    }
    return boss;
}

bool DungeonInstance::removeRunner(Player* player)
{
    runners.erase(std::remove(runners.begin(), runners.end(), player), runners.end());
    return runners.size() == 0;
}

// Dungeon Queue
void DungeonQueue::sendUpdate()
{
    std::vector<size_t> toRemove;
    std::ostringstream text;
    for (size_t i = 0; i < players.size(); ++i) {
        Player* player = players.at(i);
        if (!player || player->isOffline()) {
            toRemove.emplace_back(i);
        }
        else {
            text.str("");
            text << "Queue update!\nNew position: " << i;
            player->sendFYIBox(text.str());
        }
    }

	for (size_t i = 0; i < toRemove.size(); ++i) {
		const size_t index = toRemove[toRemove.size() - 1 - i];
		if (index < players.size()) {
			players.erase(players.begin() + index);
		}
	}

    players.shrink_to_fit();

    g_events->eventDungeonOnQueue(dungeon);
}

void DungeonQueue::onPlayerLeave(Player* player, bool sendNext)
{
    removePlayer(player);
    Dungeon* dungeon = player->getDungeon();
    if (dungeon) {
		if (sendNext) {
			dungeon->sendNextPlayer();
		}
		
        player->setDungeon(nullptr);
        player->setDungeonDifficulty(0);
        Party* party = player->getParty();
        if (dungeon->getRequiredParty().max >= 2 && party) {
            if (party->getLeader() == player) {
                PlayerVector members = party->getMembers();
                for (Player* member : members) {
                    member->setDungeon(nullptr);
                    member->setDungeonDifficulty(0);
                    g_events->eventPlayerOnQueueLeave(member, this);
                }
            }
        }
        g_events->eventPlayerOnQueueLeave(player, this);
    }
    else {
		sendUpdate();
	}
}

size_t DungeonQueue::addPlayer(Player* player)
{
    size_t queuePosition = players.size() + 1;
    players.emplace_back(player);
    players.shrink_to_fit();
    return queuePosition;
}

Player* DungeonQueue::popPlayer()
{
	if (players.empty()) {
		return nullptr;
	}

    Player* last = std::move(players.front());
    players.pop_front();
    return last;
}

bool DungeonQueue::removePlayer(Player* player)
{
	const size_t oldSize = players.size();
	players.erase(std::remove(players.begin(), players.end(), player), players.end());
	return players.size() != oldSize;
}

void DungeonQueue::switchPlayers(Player* oldPlayer, Player* newPlayer)
{
    size_t old = getPlayerPosition(oldPlayer);
	if (old >= players.size()) {
		return;
	}

    uint8_t difficulty = players.at(old)->getDungeonDifficulty();
    newPlayer->setDungeonDifficulty(difficulty);
    players.at(old) = newPlayer;
}

int16_t DungeonQueue::getPlayerPosition(Player* player) const
{
    for (size_t i = 0; i < players.size(); ++i) {
        Player* queuePlayer = players.at(i);
        if (queuePlayer && queuePlayer == player) {
            return static_cast<int16_t>(i);
        }
    }
    return -1;
}
