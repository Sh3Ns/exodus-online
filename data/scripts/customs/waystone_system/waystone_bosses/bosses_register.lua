local BOSS_POINTS = {
  ["vorgrun of the jade fangs"]   = { points = 150, storage = 551001 },
  ["fractalis the shardmaw"]      = { points = 200, storage = 551002 },
  ["frostreaver the glacialblade"]= { points = 250, storage = 551003 },
  ["rhazgor the crimson slayer"]  = { points = 300, storage = 551004 },
  ["morgrath the umbral archmage"]= { points = 350, storage = 551005 },
  ["nyxdrath the midnight terror"]= { points = 400, storage = 551006 },
}

local ONCE_PER_BOSS = false
local REWARD_MSG = "You received %d Upgrade Points for defeating %s."
local STORAGE_TOTAL_POINTS       = 716544
local STORAGE_SPENDABLE_POINTS   = 716545
local STORAGE_POINTS_INITIALIZED = 716547

local function getPlayerTotalPoints(player)
  return math.max(0, player:getStorageValue(STORAGE_TOTAL_POINTS))
end

local function getPlayerSpendablePoints(player)
  return math.max(0, player:getStorageValue(STORAGE_SPENDABLE_POINTS))
end

local function initializePlayerPoints(player)
  if player:getStorageValue(STORAGE_POINTS_INITIALIZED) ~= 1 then
    player:setStorageValue(STORAGE_TOTAL_POINTS, 0)
    player:setStorageValue(STORAGE_SPENDABLE_POINTS, 0)
    player:setStorageValue(STORAGE_POINTS_INITIALIZED, 1)
  end
end

local function gameUpgradesUpdatePoints(player)
  if type(_G.gameUpgradesUpdatePoints) == "function" then
    _G.gameUpgradesUpdatePoints(player)
  end
end

local function addUpgradePoints(player, amount)
  initializePlayerPoints(player)
  local newTotal     = getPlayerTotalPoints(player)     + amount
  local newSpendable = getPlayerSpendablePoints(player) + amount
  player:setStorageValue(STORAGE_TOTAL_POINTS,     newTotal)
  player:setStorageValue(STORAGE_SPENDABLE_POINTS, newSpendable)
  gameUpgradesUpdatePoints(player)
end

local function extractDamage(entry)
  if type(entry) == "table" then
    return tonumber(entry.total or entry.damage or entry[1] or 0) or 0
  end
  return tonumber(entry) or 0
end

local BossPointsOnKill = CreatureEvent("BossPointsOnKill")

function BossPointsOnKill.onKill(killer, target)
  local monster = target and target:getMonster()
  if not monster or monster:getMaster() then
    return true
  end

  local bossKey = monster:getName():lower()
  local cfg = BOSS_POINTS[bossKey]
  if not cfg then
    return true
  end

  local dmgMap = monster:getDamageMap()
  if not dmgMap or next(dmgMap) == nil then
    return true
  end

  local awarded = {}

  for attackerId, entry in pairs(dmgMap) do
    local p = Player(attackerId)
    if p and not awarded[attackerId] then
      local dealt = extractDamage(entry)
      if dealt > 0 then
        if not (ONCE_PER_BOSS and p:getStorageValue(cfg.storage) == 1) then
          addUpgradePoints(p, cfg.points)
          p:sendTextMessage(MESSAGE_EVENT_ADVANCE, REWARD_MSG:format(cfg.points, monster:getName()))
          awarded[attackerId] = true
          if ONCE_PER_BOSS then
            p:setStorageValue(cfg.storage, 1)
          end
        end
      end
    end
  end

  return true
end

BossPointsOnKill:register()

local BossPointsOnLogin = CreatureEvent("BossPointsOnLogin")
function BossPointsOnLogin.onLogin(player)
  player:registerEvent("BossPointsOnKill")
  return true
end
BossPointsOnLogin:type("login")
BossPointsOnLogin:register()
