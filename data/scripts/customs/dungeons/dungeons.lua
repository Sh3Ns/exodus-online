local soloRunners = {}
local groupRunners = {}
local lastSoloFetch = {}
local lastGroupFetch = {}
local cacheTime = 2 * 60

local LoginEvent = CreatureEvent("DungeonsLogin")

function LoginEvent.onLogin(player)
  player:registerEvent("DungeonsExtended")
  player:registerEvent("DungeonsLogout")
  player:registerEvent("DungeonsDeath")
  return true
end

local LogoutEvent = CreatureEvent("DungeonsLogout")

function LogoutEvent.onLogout(player)
  local dungeon = player:getDungeon()
  if dungeon then
    if player:inQueue() then
      dungeon:getQueue():onPlayerLeave(player)
    else
      dungeon:onPlayerLeave(player)
    end
  end
  return true
end

local DeathEvent = CreatureEvent("DungeonsDeath")

function DeathEvent.onDeath(player, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
  local dungeon = player:getDungeon()
  if dungeon then
    if player:inQueue() then
      dungeon:getQueue():onPlayerLeave(player)
    else
      dungeon:onPlayerLeave(player)
    end
  end
  return true
end

local ExtendedEvent = CreatureEvent("DungeonsExtended")

function ExtendedEvent.onExtendedOpcode(player, opcode, buffer)
  if opcode == ExtendedOPCodes.CODE_DUNGEONS then
    local status, json_data =
      pcall(
      function()
        return json.decode(buffer)
      end
    )
    if not status then
      return
    end

    local action = json_data.action
    local data = json_data.data

    if action == "fetch" then
      player:fetchDungeonsList()
    elseif action == "queue" then
      player:onJoinQueue(data)
    end
  end
end

function Player:onJoinQueue(data)
  local dungeons = Game.getDungeons()
  local dungeon = dungeons[data.id]
  if dungeon then
    if self:getLastDifficulty(data.id) < data.difficulty then
      return
    end

    local reqParty = dungeon:getRequiredParty()
    local party = self:getParty()
    if reqParty.max >= 2 and party then
      if party then
        if party:getLeader():getId() == self:getId() then
          if self:inQueue() then
            self:getDungeon():getQueue():onPlayerLeave(self)
          else
            if dungeon:joinQueue(self, data.difficulty) then
              self:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "queue", data = {joined = true, id = dungeon:getId()}}))
            end
          end
        end
      end
    else
      if self:inQueue() then
        self:getDungeon():getQueue():onPlayerLeave(self)
      else
        if dungeon:joinQueue(self, data.difficulty) then
          self:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "queue", data = {joined = true, id = dungeon:getId()}}))
        end
      end
    end
  end
end

function Player:fetchDungeonsList()
  local list = {}

  local dungeons = Game.getDungeons()
  for i = 1, #dungeons do
    local dungeon = dungeons[i]
    local data = {}
    local dungeonId = dungeon:getId()
    data.id = dungeonId
    data.title = dungeon:getTitle()
    data.level = dungeon:getRequiredLevel()
    local queue = dungeon:getQueue()
    data.queue = queue:getPlayersNumber()
    local boss = MonsterType(dungeon:getBoss())
    local bossOutfit = boss:outfit()
    data.boss = {
      type = bossOutfit.lookType,
      head = bossOutfit.lookHead,
      body = bossOutfit.lookBody,
      legs = bossOutfit.lookLegs,
      feet = bossOutfit.lookFeet,
      addons = bossOutfit.lookAddons
    }
    table.insert(list, data)
  end

  self:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "list", data = list}))

  self:fetchDungeonsData()
end

function Player:fetchDungeonsData()
  local dungeons = Game.getDungeons()
  for i = 1, #dungeons do
    local dungeon = dungeons[i]
    local dungeonId = dungeon:getId()
    local lastDifficulty = self:getLastDifficulty(dungeonId)

    local data = {
      id = dungeonId,
      title = dungeon:getTitle(),
      difficulty = lastDifficulty,
      req = {},
      loot = {},
      queue = {},
      challenges = {}
    }

    -- Requirements
    data.req = {}
    data.req.level = dungeon:getRequiredLevel()

    local reqParty = dungeon:getRequiredParty()
    if reqParty then
      if reqParty.min == 1 and reqParty.max == 1 then
        data.req.party = "Solo"
      else
        data.req.party = reqParty.min .. "-" .. reqParty.max
      end
    else
      data.req.party = "Solo"
    end

    local reqItemLevel = dungeon:getRequiredItemLevel()
    if reqItemLevel > 0 then
      data.req.iLvl = reqItemLevel
    end

    local reqGold = dungeon:getRequiredGold()
    if reqGold > 0 then
      data.req.gold = reqGold
    end

    local reqItems = dungeon:getRequiredItems()
    if reqItems then
      data.req.items = {}
      for i = 1, #reqItems do
        local itemType = ItemType(reqItems[i].id)
        local item_data = {clientId = itemType:getClientId(), count = reqItems[i].count}
        table.insert(data.req.items, item_data)
      end
    end

    local reqQuests = dungeon:getRequiredStorages()
    if reqQuests then
      data.req.quests = {}
      for i = 1, #reqQuests do
        table.insert(data.req.quests, reqQuests[i].details)
      end
    end

    -- Boss Loot
    data.loot = {}
    local rewards = dungeon:getRewards()
    for r = 1, #rewards do
      local reward = rewards[r]
      local itemType = ItemType(reward.itemId)
      local item_data = {clientId = itemType:getClientId(), count = reward.amount}
      table.insert(data.loot, item_data)
    end

    -- Queue
    data.queue = {}
    local queue = dungeon:getQueue()
    data.queue.players = queue:getPlayersNumber()
    data.queue.estimated = dungeon:getEstimatedQueueTime(self)

    -- Challenges
    data.challenges = {}
    local challenges = dungeon:getChallenges()
    if challenges then
      for i = 1, #challenges do
        local challengeId = challenges[i]
        local challenge = ChallengesList[challengeId]
        table.insert(
          data.challenges,
          {
            title = challenge.title,
            desc = challenge.description,
            points = challenge.points,
            completed = self:hasCompletedChallenge(challengeId)
          }
        )
      end
    end

    self:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({ action = "dungeon", data = data }))

    -- Top Runners
    for i = 1, 6 do
      self:fetchSoloRunners(dungeon:getId(), i)
      self:fetchGroupRunners(dungeon:getId(), i)
    end
  end
end

function Player:fetchSoloRunners(dungeonId, difficulty)
  if not soloRunners[dungeonId] then
    soloRunners[dungeonId] = {}
    lastSoloFetch[dungeonId] = {}
  end
  if not soloRunners[dungeonId][difficulty] then
    soloRunners[dungeonId][difficulty] = {}
    lastSoloFetch[dungeonId][difficulty] = 0
  end

  if #soloRunners[dungeonId][difficulty] > 0 then
    if lastSoloFetch[dungeonId][difficulty] + cacheTime > os.time() then
      local name = self:getName()
      local top = {}
      local foundSelf = false
      for i = 1, #soloRunners[dungeonId][difficulty] do
        local runner = soloRunners[dungeonId][difficulty][i]
        local data = {
          name = runner.name,
          time = runner.time
        }

        if runner.name == name then
          data.self = i
          foundSelf = true
          if i > 25 and not foundSelf then
            table.insert(top, data)
            break
          end
        end

        if i <= 25 then
          table.insert(top, data)
        end
      end

      self:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "solo", data = {top = top, id = dungeonId, diff = difficulty}}))
      return
    end
  end

  soloRunners[dungeonId][difficulty] = {}
  local resultId =
    db.storeQuery(
    string.format(
      [[SELECT players.name AS name, solo_runners.time as time
        FROM solo_runners
        LEFT JOIN players ON players.id = solo_runners.player_id
        WHERE dungeon_id = %d AND difficulty = %d
        ORDER BY time ASC]],
      dungeonId,
      difficulty
    )
  )

  if resultId ~= false then
    repeat
      local name = result.getDataString(resultId, "name")
      local time = result.getDataInt(resultId, "time")
      local runner = {
        name = name,
        time = time
      }
      table.insert(soloRunners[dungeonId][difficulty], runner)
    until not result.next(resultId)
    result.free(resultId)

    local name = self:getName()
    local top = {}
    local foundSelf = false
    for i = 1, #soloRunners[dungeonId][difficulty] do
      local runner = soloRunners[dungeonId][difficulty][i]
      local data = {
        name = runner.name,
        time = runner.time
      }

      if runner.name == name then
        data.self = i
        foundSelf = true
        if i > 25 and not foundSelf then
          table.insert(top, data)
          break
        end
      end

      if i <= 25 then
        table.insert(top, data)
      end
    end

    self:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "solo", data = {top = top, id = dungeonId, diff = difficulty}}))
    lastSoloFetch[dungeonId][difficulty] = os.time()
  end
end

function Player:fetchGroupRunners(dungeonId, difficulty)
  if not groupRunners[dungeonId] then
    groupRunners[dungeonId] = {}
    lastGroupFetch[dungeonId] = {}
  end
  if not groupRunners[dungeonId][difficulty] then
    groupRunners[dungeonId][difficulty] = {}
    lastGroupFetch[dungeonId][difficulty] = {}
  end

  if #groupRunners[dungeonId][difficulty] > 0 then
    if lastGroupFetch[dungeonId][difficulty] + cacheTime > os.time() then
      local name = self:getName()
      local foundSelf = false
      local top = {}
      for i = 1, #groupRunners[dungeonId][difficulty] do
        local group = groupRunners[dungeonId][difficulty][i]
        local data = {name = group.players, time = group.time}
        if group.players:find(name) then
          data.self = i
          foundSelf = true
          if i > 25 and not foundSelf then
            table.insert(top, data)
            break
          end
        end

        if i <= 25 then
          table.insert(top, data)
        end
      end

      self:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "group", data = {top = top, id = dungeonId, diff = difficulty}}))
      return
    end
  end

  groupRunners[dungeonId][difficulty] = {}

  local query = ""
  query = query .. "SELECT runs.time, players.name FROM group_runs runs "
  query = query .. "JOIN group_runners runners ON runs.id = runners.run_id "
  query = query .. "JOIN players ON players.id = runners.player "
  query = query .. "WHERE dungeon_id = %d AND difficulty = %d "
  query = query .. "ORDER BY runs.time ASC"
  local resultId = db.storeQuery(string.format(query, dungeonId, difficulty))

  if resultId ~= false then
    local lastTime = -1
    repeat
      local name = result.getDataString(resultId, "name")
      local time = result.getDataInt(resultId, "time")

      local runner = {
        name = name,
        time = time
      }
      local group = groupRunners[dungeonId][difficulty]

      if lastTime == -1 then
        lastTime = time
        group[#group + 1] = {players = name, time = time}
      else
        if lastTime == time then
          group[#group].players = group[#group].players .. "\n" .. name
        else
          lastTime = time
          group[#group + 1] = {players = name, time = time}
        end
      end
    until not result.next(resultId)
    result.free(resultId)
  end

  local name = self:getName()
  local foundSelf = false
  local top = {}
  for i = 1, #groupRunners[dungeonId][difficulty] do
    local group = groupRunners[dungeonId][difficulty][i]
    local data = {name = group.players, time = group.time}
    if group.players:find(name) then
      data.self = i
      foundSelf = true
      if i > 25 and not foundSelf then
        table.insert(top, data)
        break
      end
    end

    if i <= 25 then
      table.insert(top, data)
    end
  end

  self:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "group", data = {top = top, id = dungeonId, diff = difficulty}}))
  lastGroupFetch[dungeonId][difficulty] = os.time()
end

function Dungeon:updateSoloRun(instance)
  local instanceRunners = instance:getRunners()
  local player = instanceRunners[1]

  local finishTime = instance:getRunTime()
  local dungeonId = self:getId()
  local difficulty = instance:getDifficulty()

  if not soloRunners[dungeonId] then
    soloRunners[dungeonId] = {}
  end
  if not soloRunners[dungeonId][difficulty] then
    soloRunners[dungeonId][difficulty] = {}
  end

  local runners = soloRunners[dungeonId][difficulty]
  local name = player:getName()
  local lastRun = nil
  for i = 1, #runners do
    local runner = runners[i]
    if runner.name == name then
      lastRun = runner.time
      if runner.time > finishTime then
        db.query(
          string.format(
            "UPDATE `solo_runners` SET `time` = %d WHERE `player_id` = %d AND `dungeon_id` = %d AND `difficulty` = %d",
            finishTime,
            player:getGuid(),
            dungeonId,
            difficulty
          )
        )
        onSoloRunUpdate(dungeonId, difficulty)
        return
      end
      break
    end
  end

  if not lastRun then
    db.query(string.format("INSERT INTO `solo_runners` VALUES (%d, %d, %d, %d)", player:getGuid(), dungeonId, difficulty, finishTime))
    onSoloRunUpdate(dungeonId, difficulty)
  end
end

function onSoloRunUpdate(dungeonId, difficulty)
  soloRunners[dungeonId][difficulty] = {}
  lastSoloFetch[dungeonId][difficulty] = 0
  local players = Game.getPlayers()
  for i = 1, #players do
    players[i]:fetchSoloRunners(dungeonId, difficulty)
  end
end

function Dungeon:updateGroupRun(instance)
  local instanceRunners = instance:getRunners()
  local finishTime = instance:getRunTime()
  local difficulty = instance:getDifficulty()
  local dungeonId = self:getId()

  if not groupRunners[dungeonId] then
    groupRunners[dungeonId] = {}
  end
  if not groupRunners[dungeonId][difficulty] then
    groupRunners[dungeonId][difficulty] = {}
  end

  local topRunners = groupRunners[dungeonId][difficulty]

  local players = ""
  for _, runner in ipairs(instanceRunners) do
    players = players .. runner:getGuid() .. ","
  end
  players = players:sub(1, -2)
  local playersList = "(" .. players .. ")"

  local query = ""
  query = query .. "SELECT runs.id, runs.time "
  query = query .. "FROM group_runs runs JOIN group_runners runners ON runs.id = runners.run_id WHERE "
  query = query .. "runs.dungeon_id = %d AND runs.difficulty = %d AND runners.player IN %s "
  query = query .. "GROUP BY runs.id HAVING GROUP_CONCAT(DISTINCT runners.player ORDER BY runners.player) = '%s' LIMIT 1"

  local resultId = db.storeQuery(string.format(query, dungeonId, difficulty, playersList, players))

  local lastRunId, lastRunTime
  if resultId ~= false then
    repeat
      lastRunId = result.getDataInt(resultId, "id")
      lastRunTime = result.getDataInt(resultId, "time")
    until not result.next(resultId)
    result.free(resultId)
  end

  if lastRunId then
    if lastRunTime > finishTime then
      db.query(string.format("UPDATE `group_runs` SET `time` = %d WHERE `id` = %d", finishTime, lastRunId))
      onGroupRunUpdate(dungeonId, difficulty)
    end
    return
  end

  local runnersId = {}
  for _, runner in ipairs(instanceRunners) do
    runnersId[#runnersId + 1] = runner:getGuid()
  end
  db.query(string.format("INSERT INTO `group_runs` VALUES (NULL, %d, %d, %d)", dungeonId, difficulty, finishTime))
  onGroupRunUpdate(dungeonId, difficulty, runnersId)
end

function onGroupRunUpdate(dungeonId, difficulty, runnersId)
  if runnersId then
    local runId = db.lastInsertId()
    for _, id in ipairs(runnersId) do
      db.query(string.format("INSERT INTO `group_runners` VALUES (%d, %d)", runId, id))
    end
  end

  groupRunners[dungeonId][difficulty] = {}
  lastGroupFetch[dungeonId][difficulty] = 0
  local players = Game.getPlayers()
  for i = 1, #players do
    players[i]:fetchGroupRunners(dungeonId, difficulty)
  end
end

function Player:inQueue()
  local dungeon = self:getDungeon()
  if dungeon then
    if dungeon:getQueue():getPlayerPosition(self) ~= -1 then
      return true
    end
  end
  return false
end

function Player:removeBonusObjective(id)
  self:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "objective", data = {id = id}}))
end

function Player:finishBonusObjective(id)
  self:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "objective", data = {id = id, finished = true}}))
end

function DungeonInstance:removeBonusObjective(id)
  local runners = self:getRunners()
  for _, runner in ipairs(runners) do
    runner:removeBonusObjective(id)
  end
end

function DungeonInstance:finishBonusObjective(id)
  local runners = self:getRunners()
  for _, runner in ipairs(runners) do
    runner:finishBonusObjective(id)
  end
end

function onDungeonPartyJoin(party, player)
  local leader = party:getLeader()
  if leader:inQueue() and player:inQueue() then
    do
      local dungeon = player:getDungeon()
      if dungeon then
        dungeon:getQueue():onPlayerLeave(player)
        player:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "queue", data = {joined = false}}))
      end
    end
    do
      local dungeon = leader:getDungeon()
      if dungeon then
        leader:popupFYI("Someone joined party when in queue. Your party is now removed from queue.")
        dungeon:getQueue():onPlayerLeave(leader)
        leader:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "queue", data = {joined = false}}))
        local members = party:getMembers()
        for _, member in ipairs(members) do
          member:setDungeon(nil)
          member:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "queue", data = {joined = false}}))
        end
      end
    end
    return
  end

  local dungeon = leader:getDungeon()
  if dungeon then
    local instance = dungeon:getPlayerInstance(leader)
    if instance then
      return
    end
    if not dungeon:canJoin(player, true) then
      leader:popupFYI(string.format("New member %s doesn't meet dungeon requirements. Your party is now removed from queue.", player:getName()))
      dungeon:getQueue():onPlayerLeave(leader)
      leader:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "queue", data = {joined = false}}))
      local members = party:getMembers()
      for _, member in ipairs(members) do
        member:setDungeon(nil)
        member:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "queue", data = {joined = false}}))
      end
      return
    else
      player:popupFYI(
        string.format("You have joined party in queue for %s. Position in queue: %d", dungeon:getTitle(), dungeon:getQueue():getPlayerPosition(leader))
      )
    end
  end
end

function onDungeonPartyLeave(party, player)
  local leader = party:getLeader()
  local dungeon = leader:getDungeon()
  if leader:inQueue() then
    leader:popupFYI("Someone left party, you are removed from queue.")
    dungeon:getQueue():onPlayerLeave(leader)
    leader:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "stopQueue"}))
    local members = party:getMembers()
    for _, member in ipairs(members) do
      member:popupFYI("Someone left party, you are removed from queue.")
      member:setDungeon(nil)
      member:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "stopQueue"}))
    end
  end
end

function onDungeonPartyDisband(party)
  local leader = party:getLeader()
  local dungeon = leader:getDungeon()
  if leader:inQueue() then
    leader:popupFYI("Party was disbanded and removed from queue.")
    dungeon:getQueue():onPlayerLeave(leader)
    leader:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "stopQueue"}))
    local members = party:getMembers()
    for _, member in ipairs(members) do
      member:popupFYI("Party was disbanded and removed from queue.")
      member:setDungeon(nil)
      member:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "stopQueue"}))
    end
  end
end

function onDungeonPartyLeaderPass(party, oldLeader, newLeader)
  local dungeon = oldLeader:getDungeon()
  if dungeon then
    local instance = dungeon:getPlayerInstance(oldLeader)
    if instance then
      return
    end
    dungeon:getQueue():switchPlayer(oldLeader, newLeader)
  end
end

function Player:getItemLevel()
  local iLvl = 0
  for slot = CONST_SLOT_HEAD, CONST_SLOT_AMMO do
    local item = self:getSlotItem(slot)
    if item then
      local itemType = item:getType()
      if itemType:usesSlot(slot) then
        if itemType:isTwoHanded() then
          iLvl = iLvl + (item:getItemLevel() * 2)
        else
          iLvl = iLvl + item:getItemLevel()
        end
      end
    end
  end
  return iLvl
end

function Player:setLastDifficulty(dungeonId, difficulty)
  self:setStorageValue(PlayerStorageKeys.dungeonsDifficulty + dungeonId, difficulty)
  self:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "difficulty", data = {id = dungeonId, difficulty = difficulty}}))
end

function Player:getLastDifficulty(dungeonId)
  local lastDifficulty = self:getStorageValue(PlayerStorageKeys.dungeonsDifficulty + dungeonId)
  if lastDifficulty == -1 then
    lastDifficulty = 1
    self:setStorageValue(PlayerStorageKeys.dungeonsDifficulty + dungeonId, 1)
  end

  return lastDifficulty
end

local BossDeathEvent = CreatureEvent("DungeonBossDeath")
local MonsterDeathEvent = CreatureEvent("DungeonMonsterDeath")

function BossDeathEvent.onDeath(target, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
  if killer:isPlayer() then
    local dungeon = killer:getDungeon()
    if dungeon then
      local instance = dungeon:getPlayerInstance(killer)
      if instance then
        dungeon:onBossKill(instance)
        local runners = instance:getRunners()
        for _, runner in ipairs(runners) do
          runner:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "killed", data = {boss = true}}))
        end
      end
    end
  end
  return true
end

function MonsterDeathEvent.onDeath(target, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
  if killer:isPlayer() then
    local dungeon = killer:getDungeon()
    if dungeon then
      local instance = dungeon:getPlayerInstance(killer)
      if instance then
        local total = instance:getMonstersTotalCount()
        local required = math.floor((total * (dungeon:getKillPercent() / 100)) + 0.5)
        local left = instance:getMonstersCount() - 1
        local runners = instance:getRunners()

        if left == 0 then
          if dungeon:getTitle() == "Rootkraken" then
            for _, runner in ipairs(runners) do
              if not runner:hasCompletedChallenge(ChallengesIndex.ROOTKRAKEN_HUNTER) then
                runner:completeChallenge(ChallengesIndex.ROOTKRAKEN_FINISH)
              end
            end
          end
          if dungeon:getTitle() == "Forbidden" then
            for _, runner in ipairs(runners) do
              if not runner:hasCompletedChallenge(ChallengesIndex.FORBIDDEN_HUNTER) then
                runner:completeChallenge(ChallengesIndex.FORBIDDEN_FINISH)
              end
            end
          end
          if dungeon:getTitle() == "MasterElement" then
            for _, runner in ipairs(runners) do
              if not runner:hasCompletedChallenge(ChallengesIndex.MASTER_ELEMENTS_HUNTER) then
                runner:completeChallenge(ChallengesIndex.MASTER_ELEMENTS_FINISH)
              end
            end
          end
          if dungeon:getTitle() == "Bones" then
            for _, runner in ipairs(runners) do
              if not runner:hasCompletedChallenge(ChallengesIndex.BONES_HUNTER) then
                runner:completeChallenge(ChallengesIndex.BONES_FINISH)
              end
            end
          end
        end

        local percent = left > 0 and 100 - math.floor((((required - (total - left)) / required) * 100) + 0.5) or 100
        if percent >= 100 and not instance:isBossSpawned() then
          instance:spawnBoss()
        end
        instance:setMonstersCount(left)

        for _, runner in ipairs(runners) do
          runner:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "killed", data = {percent = percent, left = left}}))
        end
      end
    end
  end
  return true
end

BossDeathEvent:type("death")
BossDeathEvent:register()
MonsterDeathEvent:type("death")
MonsterDeathEvent:register()
LoginEvent:type("login")
LoginEvent:register()
LogoutEvent:type("logout")
LogoutEvent:register()
DeathEvent:type("death")
DeathEvent:register()
ExtendedEvent:type("extendedopcode")
ExtendedEvent:register()
