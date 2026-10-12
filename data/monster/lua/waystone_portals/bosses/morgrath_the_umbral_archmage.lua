local mType = Game.createMonsterType("Morgrath the Umbral Archmage")
local monster = {}
monster.description = "a Morgrath the Umbral Archmage"
monster.experience = 450000
monster.outfit = {
	lookType = 1424
}

monster.health = 550000
monster.maxHealth = 550000
monster.corpse = 26691
monster.speed = 850
monster.maxSummons = 0
monster.race = "magical"
monster.raceid = 1276

monster.changeTarget = {
	interval = 4000,
	chance = 20
}

monster.flags = {
	summonable = false,
	attackable = true,
	hostile = true,
	convinceable = false,
	pushable = true,
	illusionable = false,
	canPushItems = true,
	canPushCreatures = true,
	staticAttackChance = 90,
	targetDistance = 1,
  isRewardBoss = true,
	runHealth = 0,
	healthHidden = false,
	isBlockable = false,
	canWalkOnEnergy = true,
	canWalkOnFire = true,
	canWalkOnPoison = true,
	pet = false
}

monster.summons = {
}

monster.events = {
	"playerAttackSound",
	"archmage_damage",
}

monster.voices = {
}

monster.loot = { 
	{id = "Crystal Coin", chance = 100000, maxCount = 45},
	{id = "mythic mana potion", chance = 45000, maxCount = 8},
	{id = "mythic health potion", chance = 45000, maxCount = 8},
	{id = "mythic spirit potion", chance = 45000, maxCount = 8},
	{id = "runescribed parchment", chance = 25000, maxCount = 1},
	{id = "aethus fragment", chance = 20000, maxCount = 1},
	{id = "envenomed heart", chance = 20000, maxCount = 1},
	{id = "corrupted skull", chance = 20000, maxCount = 1},
	{id = "mystic essence", chance = 20000, maxCount = 1},
	{id = "armor shard", chance = 20000, maxCount = 1},
	{id = "runic stone shard", chance = 20000, maxCount = 1},
  {id = "myst charged stone", chance = 60000, maxCount = 5},
	{id = "seraphic charged stone", chance = 60000, maxCount = 5},
	{id = "dawnforged charged stone", chance = 60000, maxCount = 5},
  {id = "molten charged stone", chance = 60000, maxCount = 5},
	{id = "blacksmith hammer", chance = 30000, maxCount = 2},
  {id = "vial of fragment blood", chance = 15000, maxCount = 2},
  {id = "myst emblem", chance = 50000, maxCount = 1},
  {id = "stoic iks robe", chance = 3500},
	{id = "iks footwraps", chance = 3500},
	{id = "stoic iks casque", chance = 3500},
	{id = "stoic iks headpiece", chance = 3500},
	{id = "arcane dragon robe", chance = 3500},
	{id = "dauntless dragon scale armor", chance = 3500},
	{id = "mystical dragon robe", chance = 3500},
	{id = "stoic iks chestplate", chance = 3500},
	{id = "stoic iks cuirass", chance = 3500},
	{id = "unerring dragon scale armor", chance = 3500},
	{id = "stoic iks culet", chance = 3500},
	{id = "stoic iks faulds", chance = 3500},
	{id = "stoic iks boots", chance = 3500},
	{id = "stoic iks sandals", chance = 3500},
	{id = "seraphic emblem", chance = 50000, maxCount = 1},
  {id = "molten emblem", chance = 50000, maxCount = 1},
	{id = "dawnforged emblem", chance = 50000, maxCount = 1},
	{id = "empowered stone shard", chance = 50000, maxCount = 1},
  {id = "exalted orb", chance = 70000, maxCount = 15},
	{id = "chaos orb", chance = 45000, maxCount = 12},
	{id = "divine orb", chance = 30000, maxCount = 9},
	{id = "angel orb", chance = 20000, maxCount = 3},
  {id = "mirror of kalandra", chance = 5000, maxCount = 1},
  {id = "boss token", chance = 8000, maxCount = 2},
	{id = "exercise token", chance = 8000, maxCount = 2},
	{id = "ticket roulette", chance = 5000, maxCount = 2},
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, minDamage = -1800, maxDamage = -3000},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_ARCANEDAMAGE, minDamage = -1660, maxDamage = -2850, range = 8, shootEffect = 107, target = true},
	{name ="combat", interval = 1000, chance = 15, type = COMBAT_HOLYDAMAGE, minDamage = -2000, maxDamage = -3000, shootEffect = 103, effect = 223 , range = 8, target = false},
	{name ="combat", interval = 1000, chance = 13, type = COMBAT_ICEDAMAGE, minDamage = -1600, maxDamage = -3490, range = 8, shootEffect = 228, effect = 282, target = false},
	{name ="combat", interval = 1000, chance = 10, type = COMBAT_EARTHDAMAGE, minDamage = -1900, maxDamage = -3500, range = 8, shootEffect = 83, target = false},
	{name ="combat", interval = 2000, chance = 10, type = COMBAT_FIREDAMAGE, minDamage = -2000, maxDamage = -4100, radius = 8, effect = 334, target = false},
	{name ="condition", type = CONDITION_BEWITCHED, interval = 2000, chance = 10, minDamage = -1980, maxDamage = -2800, radius = 8, effect = 353, target = false},
}

monster.defenses = {
	defense = 200,
	armor = 200,
}

monster.elements = {
	{type = COMBAT_PHYSICALDAMAGE, percent = 0},
	{type = COMBAT_ENERGYDAMAGE, percent = 0},
	{type = COMBAT_EARTHDAMAGE, percent = 0},
	{type = COMBAT_FIREDAMAGE, percent = 0},
	{type = COMBAT_LIFEDRAIN, percent = 0},
	{type = COMBAT_MANADRAIN, percent = 0},
	{type = COMBAT_DROWNDAMAGE, percent = 0},
	{type = COMBAT_ICEDAMAGE, percent = 0},
	{type = COMBAT_HOLYDAMAGE , percent = 0},
	{type = COMBAT_DEATHDAMAGE , percent = 0},
	{type = COMBAT_WATERDAMAGE, percent = 0},
	{type = COMBAT_ARCANEDAMAGE, percent = 0},
}

monster.immunities = {
	{type = "physical", condition = false},
	{type = "energy", condition = false},
	{type = "fire", condition = false},
	{type = "earth", condition = false},
	{type = "ice", condition = false},
	{type = "drown", condition = true},
	{type = "holy", condition = false},
	{type = "death", condition = false},
	{type = "water", condition = false},
	{type = "arcane", condition = false},
	{type = "lifedrain", combat = true},
	{type = "paralyze", condition = true},
	{type = "invisible", condition = true}
}

local AREAS = {
  -- Map 1
  {
    fromPos = Position(33453, 33334, 7),
    toPos   = Position(33483, 33359, 7),
  },
  -- Map 2
  {
    fromPos = Position(33109, 33007, 7),
    toPos   = Position(33141, 33040, 7),
  },
}

local SpawnMonsterName = "Katoi Pillar"
local MaxTries = 3
local MaxMonstersPerArea = 1
local SpawnInterval = 45
local KatoiPillarDuration = 30
local StorageSpawnNext = 900001
local StorageAreaIndex = 900002

local function posInRect(p, a, b)
  local x1, x2 = math.min(a.x, b.x), math.max(a.x, b.x)
  local y1, y2 = math.min(a.y, b.y), math.max(a.y, b.y)
  return p.z == a.z and p.x >= x1 and p.x <= x2 and p.y >= y1 and p.y <= y2
end

local function areaOfPosition(p)
  for i, rect in ipairs(AREAS) do
    if posInRect(p, rect.fromPos, rect.toPos) then
      return i
    end
  end
  return nil
end

local function randomPosChoice(a, b)
  local x1, x2 = math.min(a.x, b.x), math.max(a.x, b.x)
  local y1, y2 = math.min(a.y, b.y), math.max(a.y, b.y)
  local x = math.random(x1, x2)
  local y = math.random(y1, y2)
  return Position(x, y, a.z)
end

local function checkTileSpawn(pos)
  local tile = Tile(pos)
  if not tile then return false end
  if tile:hasFlag(TILESTATE_PROTECTIONZONE) then return false end
  if tile:hasFlag(TILESTATE_BLOCKSOLID) then return false end
  if tile:getTopCreature() then return false end

  local ground = tile:getGround()
  if not ground then return false end
  if ground:hasProperty(CONST_PROP_BLOCKSOLID) then return false end

  return true
end

local function radiusCalculation(a, b)
  local x1, x2 = math.min(a.x, b.x), math.max(a.x, b.x)
  local y1, y2 = math.min(a.y, b.y), math.max(a.y, b.y)
  local cx = math.floor((x1 + x2) / 2)
  local cy = math.floor((y1 + y2) / 2)
  local rx = math.floor((x2 - x1) / 2)
  local ry = math.floor((y2 - y1) / 2)
  return Position(cx, cy, a.z), rx, ry
end

local function countSpawnsInRect(rect, name)
  local center, rx, ry = radiusCalculation(rect.fromPos, rect.toPos)
  local specs = Game.getSpectators(center, false, false, rx, rx, ry, ry)
  local count, lname = 0, name:lower()
  for _, cr in ipairs(specs) do
    if cr:isMonster() and cr:getName():lower() == lname then
      count = count + 1
    end
  end
  return count
end

local function spawnPillarInRect(rect)
  if countSpawnsInRect(rect, SpawnMonsterName) >= MaxMonstersPerArea then
    return false
  end

  for _ = 1, MaxTries do
    local pos = randomPosChoice(rect.fromPos, rect.toPos)
    if checkTileSpawn(pos) then
      local mon = Game.createMonster(SpawnMonsterName, pos, false, true)
      if mon then
        mon:setNoMove(true)

        local id = mon:getId()
        addEvent(function()
          local m2 = Creature(id)
          if m2 and m2:isMonster() and not m2:isRemoved() then
            m2:remove()
          end
        end, KatoiPillarDuration * 1000)

        return true
      end
    end
  end
  return false
end


local THINK_DELAY = 3
local THINK_STORAGE = 900003

mType.onThink = function(self, interval)
  local now = os.time()
  local nextThink = self:getStorageValue(THINK_STORAGE)

  if nextThink ~= -1 and now < nextThink then
    return
  end

  self:setStorageValue(THINK_STORAGE, now + THINK_DELAY)

  local pos = self:getPosition()
  local idx = areaOfPosition(pos)
  if not idx then return end

  self:setStorageValue(StorageAreaIndex, idx)

  local nextAt = self:getStorageValue(StorageSpawnNext)
  if nextAt == -1 or now >= nextAt then
    spawnPillarInRect(AREAS[idx])
    self:setStorageValue(StorageSpawnNext, now + SpawnInterval)
  end
end

mType.onAppear = function(monster, creature)
  if monster:getId() == creature:getId() then
    monster:setStorageValue(StorageSpawnNext, os.time() + 20)
    local idx = areaOfPosition(monster:getPosition())
    if idx then
      monster:setStorageValue(StorageAreaIndex, idx)
    end
  end
end

mType.onDisappear = function(monster, creature)
  if monster:getId() ~= creature:getId() then return end
  local idx = monster:getStorageValue(StorageAreaIndex)
  if type(idx) ~= "number" or not AREAS[idx] then
    return
  end

  local rect = AREAS[idx]
  local center, rx, ry = radiusCalculation(rect.fromPos, rect.toPos)
  local specs = Game.getSpectators(center, false, false, rx, rx, ry, ry)
  for _, cr in ipairs(specs) do
    if cr:isMonster() and cr:getName():lower() == SpawnMonsterName:lower() then
      cr:remove()
    end
  end
end

mType.onMove = function(monster, creature, fromPosition, toPosition)
	if monster:getId() == creature:getId() then
	end
end

mType.onSay = function(monster, creature, type, message)
end

local ARCHMAGE_NAME = "Morgrath the Umbral Archmage"
local PillarName = "Katoi Pillar"

local function archmageNearPillar(archmage)
    local p = archmage:getPosition()
    local check = {
        Position(p.x + 1, p.y, p.z),
        Position(p.x - 1, p.y, p.z),
        Position(p.x, p.y + 1, p.z),
        Position(p.x, p.y - 1, p.z),
    }
    for _, pos in ipairs(check) do
        local tile = Tile(pos)
        if tile then
            local top = tile:getTopCreature()
            if top and top:isMonster() and top:getName():lower() == PillarName:lower() then
                return true
            end
        end
    end
    return false
end

local evt = CreatureEvent("archmage_damage")
function evt.onHealthChange(target, source, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
    if not target or not target:isMonster() then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end
    if target:getName() ~= ARCHMAGE_NAME then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    if not archmageNearPillar(target) then
        return 0, primaryType, 0, secondaryType
    end
    return primaryDamage, primaryType, secondaryDamage, secondaryType
end
evt:register()


mType:register(monster)