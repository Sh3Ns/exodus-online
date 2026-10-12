#ifndef DUNGEON_H
#define DUNGEON_H

#include <deque>

#include "position.h"

class Player;
class Dungeon;
class Monster;

struct StorageRequire
{
	StorageRequire(uint32_t key, int32_t value, std::string details, std::string error) : key(key), value(value), details(std::move(details)), error(std::move(error)) {};

	uint32_t key;
	int32_t value;
	std::string details;
	std::string error;
};

struct PartyRequire
{
	uint8_t min = 1;
	uint8_t max = 1;
};

struct TimeRequire
{
	uint32_t storage = 0;
	uint32_t time = 0;
};

struct DungeonRequire
{
	uint16_t level = 0;

	TimeRequire time;

	uint64_t gold = 0;
	uint64_t itemLevel = 0;

	PartyRequire party;

	std::map<uint16_t, uint8_t> items;
	std::vector<StorageRequire> storage;
};

struct DungeonReward
{
	DungeonReward(uint16_t itemId, uint8_t amount, uint8_t chance) : itemId(itemId), amount(amount), chance(chance) {};
	uint16_t itemId;
	uint8_t amount;
	uint8_t chance;
};

class DungeonQueue
{
public:
	DungeonQueue() = default;
	virtual ~DungeonQueue() = default;

public:
	void sendUpdate();

	void onPlayerLeave(Player* player, bool sendNext = false);
	size_t addPlayer(Player* player);
	Player* popPlayer();
	bool removePlayer(Player* player);
	void switchPlayers(Player* oldPlayer, Player* newPlayer);

	std::deque<Player*> getPlayers() {
		return players;
	}

	size_t getPlayersNumber() const {
		return players.size();
	}

	int16_t getPlayerPosition(Player* player) const;

	void setDungeon(Dungeon* dungeon) {
		this->dungeon = dungeon;
	}

	Dungeon* getDungeon() {
		return dungeon;
	}

private:
	std::deque<Player*> players;

	Dungeon* dungeon = nullptr;
};

class DungeonInstance
{
public:
	DungeonInstance() = default;
	DungeonInstance(Position position) : position(std::move(position)) {};
	virtual ~DungeonInstance() = default;

public:
	void start(Dungeon* dungeon, Player* player);
	void start(Dungeon* dungeon, const std::vector<Player*>& members);

	void build(const std::string& mapFile, uint8_t difficulty);
	void destroy(const std::string& mapFile);

	bool isFree() const {
		return free;
	}

	void setPosition(Position position) {
		this->position = std::move(position);
	}

	const Position& getPosition() const {
		return position;
	}

	void setId(uint16_t id) {
		this->id = id;
	}

	uint16_t getId() const {
		return id;
	}

	void addRunner(Player* player) {
		runners.emplace_back(player);
		runners.shrink_to_fit();
	}

	bool hasRunner(Player* player) {
		return std::find(runners.begin(), runners.end(), player) != runners.end();
	}

	std::vector<Player*> getRunners() {
		return runners;
	}

	bool removeRunner(Player* player);

	void setStartTime(uint16_t time) {
		this->startTime = time;
	}

	int64_t getStartTime() const {
		return startTime;
	}

	void setRunTime(int64_t time) {
		this->runTime = time;
	}

	int64_t getRunTime() const {
		return runTime;
	}

	uint8_t getDifficulty() const {
		return difficulty;
	}

	void setDungeon(Dungeon* dungeon) {
		this->dungeon = dungeon;
	}

	Dungeon* getDungeon() {
		return dungeon;
	}

	void setMonstersTotalCount(uint16_t monsters) {
		this->monsters = monsters;
		this->monstersTotal = monsters;
	}

	uint16_t getMonstersTotalCount() const {
		return monstersTotal;
	}

	void setMonstersCount(uint16_t monsters) {
		this->monsters = monsters;
	}

	uint16_t getMonstersCount() const {
		return monsters;
	}

	Monster* getBoss();
	bool spawnBoss();

	bool isBossSpawned() const {
		return bossSpawned;
	}

private:
	Position position;

	std::vector<Player*> runners;

	Dungeon* dungeon = nullptr;

	Monster* boss = nullptr;

	bool free = true;
	bool bossSpawned = false;

	uint8_t difficulty = 1;

	uint16_t id = 0;
	int64_t startTime = 0;
	int64_t runTime = 0;
	uint16_t monsters = 0;
	uint16_t monstersTotal = 0;
};

class Dungeon
{
public:
	Dungeon();
	virtual ~Dungeon() = default;

public:
	bool joinQueue(Player* player, uint8_t difficulty);
	void prepare(Player* player, uint8_t difficulty);
	void start(uint32_t pid, DungeonInstance* instance, std::vector<Player*>& members);
	void onStart(DungeonInstance* instance, Player* player);
	void timeout(uint32_t pid);
	void onPlayerLeave(Player* player);
	void sendNextPlayer();
	bool canJoin(Player* player, bool partyMember = false, bool prepare = false);
	void onDungeonSuccess(DungeonInstance* instance);
	void onDungeonFail(DungeonInstance* instance);
	void preBuild();

	void setTitle(std::string title) {
		this->title = std::move(title);
	}

	const std::string& getTitle() const {
		return title;
	}

	void setDuration(uint32_t duration) {
		this->duration = duration;
	}

	uint32_t getDuration() const {
		return duration;
	}

	void setKillPercent(uint8_t value) {
		killPercent = value;
	}

	uint8_t getKillPercent() const {
		return killPercent;
	}

	void setRequiredLevel(uint16_t level) {
		require.level = level;
	}

	uint16_t getRequiredLevel() const {
		return require.level;
	}

	void setRequiredItemLevel(uint64_t itemLevel) {
		require.itemLevel = itemLevel;
	}

	uint64_t getRequiredItemLevel() const {
		return require.itemLevel;
	}

	void setRequiredParty(uint8_t min, uint8_t max) {
		require.party.min = min;
		require.party.max = max;
	}

	const PartyRequire& getRequiredParty() const {
		return require.party;
	}

	void setRequiredGold(uint64_t value) {
		require.gold = value;
	}

	uint64_t getRequiredGold() const {
		return require.gold;
	}

	void addRequiredItem(uint16_t itemId, uint8_t count) {
		require.items.emplace(itemId, count);
	}

	const std::map<uint16_t, uint8_t>& getRequiredItems() const {
		return require.items;
	}

	void addRequiredStorage(uint32_t key, int32_t value, std::string details, std::string error) {
		require.storage.emplace_back(key, value, std::move(details), std::move(error));
		require.storage.shrink_to_fit();
	}

	const std::vector<StorageRequire>& getRequiredStorages() const {
		return require.storage;
	}

	void setRequiredTime(uint32_t timeStorage, uint32_t time) {
		require.time.storage = timeStorage;
		require.time.time = time;
	}

	const TimeRequire& getRequiredTime() const {
		return require.time;
	}

	void addReward(uint16_t itemId, uint8_t amount, uint8_t chance) {
		rewards.emplace_back(itemId, amount, chance);
	}

	const std::vector<DungeonReward>& getRewards() const {
		return rewards;
	}

	void addInstance(Position position);

	void onBossKill(DungeonInstance* instance);

	DungeonInstance* getInstance(size_t index) {
		return instances.at(index);
	}

	DungeonInstance* getFreeInstance();

	DungeonInstance* getPlayerInstance(Player* player);

	void setMapFile(std::string mapFile) {
		this->mapFile = std::move(mapFile);
	}

	const std::string& getMapFile() const {
		return mapFile;
	}

	DungeonQueue* getQueue() {
		return queue;
	}

	void setId(uint8_t id) {
		this->id = id;
	}

	uint8_t getId() const {
		return id;
	}

	void setBoss(std::string boss, Position spawnPosition) {
		this->boss = std::move(boss);
		this->bossPosition = std::move(spawnPosition);
	}

	const std::string& getBoss() const {
		return boss;
	}

	const Position& getBossPosition() const {
		return bossPosition;
	}

	void addChallenge(uint16_t id) {
		challenges.emplace_back(id);
		challenges.shrink_to_fit();
	}

	const std::vector<uint16_t>& getChallenges() const {
		return challenges;
	}

	void addBonusObjective(std::string text) {
		bonusObjectives.emplace_back(std::move(text));
		bonusObjectives.shrink_to_fit();
	}

	const std::vector<std::string>& getBonusObjectives() const {
		return bonusObjectives;
	}

	uint32_t getEstimatedQueueTime(Player* player) const;

	void setStartPosition(Position startPosition) {
		this->startPosition = std::move(startPosition);
	}

	const Position& getStartPosition() const {
		return startPosition;
	}

private:
	std::string title;
	std::string mapFile;
	std::string boss;

	Position bossPosition;
	Position startPosition;

	uint8_t id = 0;
	uint8_t killPercent = 100;

	uint32_t duration = 0;

	std::map<uint32_t, uint64_t> timeoutEvent;

	std::vector<DungeonReward> rewards;
	std::vector<DungeonInstance*> instances;
	std::vector<uint16_t> challenges;
	std::vector<std::string> bonusObjectives;

	DungeonRequire require;

	DungeonQueue* queue = nullptr;
};

#endif
