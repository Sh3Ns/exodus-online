local mType = Game.createMonsterType("Nyxdrath the Midnight Terror")
local monster = {}
monster.description = "a Nyxdrath the Midnight Terror"
monster.experience = 700000
monster.outfit = {
	lookType = 1426
}

monster.health = 800000
monster.maxHealth = 800000
monster.corpse = 26691
monster.speed = 1000
monster.maxSummons = 0
monster.race = "dragon"
monster.raceid = 1302

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
	"nyxdrath_damage",
}

monster.voices = {
}

monster.loot = { 
	{id = "Crystal Coin", chance = 100000, maxCount = 80},
	{id = "mythic mana potion", chance = 45000, maxCount = 10},
	{id = "mythic health potion", chance = 45000, maxCount = 10},
	{id = "mythic spirit potion", chance = 45000, maxCount = 10},
  {id = "petrified dragon wings", chance = 55000, maxCount = 1},
  {id = "petrified dragon foot", chance = 50000, maxCount = 1},
  {id = "petrified dragon head", chance = 48000, maxCount = 1},
  {id = "nyxdrath heart", chance = 50000, maxCount = 2},
  {id = "runescribed parchment", chance = 40000, maxCount = 1},
  {id = "aethus fragment", chance = 25000, maxCount = 1},
  {id = "envenomed heart", chance = 25000, maxCount = 1},
  {id = "corrupted skull", chance = 25000, maxCount = 1},
  {id = "mystic essence", chance = 25000, maxCount = 1},
  {id = "armor shard", chance = 25000, maxCount = 1},
  {id = "runic stone shard", chance = 25000, maxCount = 1},
  {id = "vial of fragment blood", chance = 25000, maxCount = 3},
  {id = "myst charged stone", chance = 60000, maxCount = 6},
	{id = "seraphic charged stone", chance = 60000, maxCount = 6},
  {id = "molten charged stone", chance = 60000, maxCount = 6},
	{id = "dawnforged charged stone", chance = 60000, maxCount = 6},
	{id = "blacksmith hammer", chance = 30000, maxCount = 3},
  {id = "myst emblem", chance = 80000, maxCount = 2},
	{id = "seraphic emblem", chance = 80000, maxCount = 2},
  {id = "molten emblem", chance = 80000, maxCount = 2},
	{id = "dawnforged emblem", chance = 80000, maxCount = 2},
  {id = "stoic iks robe", chance = 5500},
	{id = "iks footwraps", chance = 5500},
	{id = "stoic iks casque", chance = 5500},
	{id = "stoic iks headpiece", chance = 5500},
	{id = "arcane dragon robe", chance = 5500},
	{id = "dauntless dragon scale armor", chance = 5500},
	{id = "mystical dragon robe", chance = 5500},
	{id = "stoic iks chestplate", chance = 5500},
	{id = "stoic iks cuirass", chance = 5500},
	{id = "unerring dragon scale armor", chance = 5500},
	{id = "stoic iks culet", chance = 5500},
	{id = "stoic iks faulds", chance = 5500},
	{id = "stoic iks boots", chance = 5500},
	{id = "stoic iks sandals", chance = 5500},
	{id = "empowered stone shard", chance = 80000, maxCount = 2},
  {id = "exalted orb", chance = 80000, maxCount = 20},
	{id = "chaos orb", chance = 55000, maxCount = 15},
	{id = "divine orb", chance = 40000, maxCount = 12},
	{id = "angel orb", chance = 30000, maxCount = 5},
  {id = "mirror of kalandra", chance = 8000, maxCount = 3},
  {id = "boss token", chance = 20000, maxCount = 2},
	{id = "exercise token", chance = 20000, maxCount = 2},
	{id = "ticket roulette", chance = 12000, maxCount = 2},
}

monster.attacks = {
	{name ="melee", interval = 2000, chance = 100, minDamage = -2000, maxDamage = -4000},
	{name ="combat", interval = 2000, chance = 7, type = COMBAT_PHYSICALDAMAGE, minDamage = -2950, maxDamage = -3900, length = 8, spread = 3, effect = 208, target = false},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_LIFEDRAIN, minDamage = -1850, maxDamage = -3260, length = 7, spread = 3, effect = 274, target = false},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_EARTHDAMAGE, minDamage = -1940, maxDamage = -3100, radius = 5, effect = 367, target = false},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_ENERGYDAMAGE, minDamage = -1720, maxDamage = -3950, length = 8, spread = 3, effect = 358, target = false},
	{name ="combat", interval = 2000, chance = 20, type = COMBAT_FIREDAMAGE, minDamage = -1640, maxDamage = -2800, radius = 5, effect = 234, target = true},
	{name ="combat", interval = 2000, chance = 19, type = COMBAT_MANADRAIN, minDamage = -2000, maxDamage = -4300, range = 7, radius = 6, shootEffect = 112, effect = 255, target = true},
}

monster.defenses = {
	defense = 220,
	armor = 220,
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
	{type = "energy", condition = true},
	{type = "fire", condition = true},
	{type = "earth", condition = true},
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
  { fromPos = Position(32944, 33332, 8), toPos = Position(32956, 33345, 8) }, -- map 1
  { fromPos = Position(33315, 33477, 7), toPos = Position(33325, 33487, 7) }, -- map 2
}
local spawnInterval = 45
local pillarDuration = 30
local firstDelayPillar = 20
local maxTries = 3
local maxPillarsPerArea = 1
local StorageSpawnNext = 917341
local StorageAreaIndex = 917342

local PILLARS = {
  { name = "Pillar of Blades", dmg = COMBAT_PHYSICALDAMAGE },
  { name = "Pillar of Light", dmg = COMBAT_ENERGYDAMAGE  },
  { name = "Pillar of Forest", dmg = COMBAT_EARTHDAMAGE   },
  { name = "Pillar of Flames", dmg = COMBAT_FIREDAMAGE    },
  { name = "Pillar of Frost", dmg = COMBAT_ICEDAMAGE     },
  { name = "Pillar of Sun", dmg = COMBAT_HOLYDAMAGE    },
  { name = "Pillar of Death", dmg = COMBAT_DEATHDAMAGE   },
  { name = "Pillar of Arcana", dmg = COMBAT_ARCANEDAMAGE  },
  { name = "Pillar of Jur", dmg = COMBAT_WATERDAMAGE  },
}
local PILLAR_NAME_TO_TYPE = {}
for _, p in ipairs(PILLARS) do
  PILLAR_NAME_TO_TYPE[p.name:lower()] = p.dmg
end

local function posInRect(p, a, b)
  local x1, x2 = math.min(a.x, b.x), math.max(a.x, b.x)
  local y1, y2 = math.min(a.y, b.y), math.max(a.y, b.y)
  return p.z == a.z and p.x >= x1 and p.x <= x2 and p.y >= y1 and p.y <= y2
end

local function areaOfPosition(p)
  for i, r in ipairs(AREAS) do
    if posInRect(p, r.fromPos, r.toPos) then return i end
  end
  return nil
end

local function isTileSpawnable(pos)
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

local function randomPosInRect(a, b)
  local x1, x2 = math.min(a.x, b.x), math.max(a.x, b.x)
  local y1, y2 = math.min(a.y, b.y), math.max(a.y, b.y)
  return Position(math.random(x1, x2), math.random(y1, y2), a.z)
end

local function rectCenterAndRadii(a, b)
  local x1, x2 = math.min(a.x, b.x), math.max(a.x, b.x)
  local y1, y2 = math.min(a.y, b.y), math.max(a.y, b.y)
  local cx = math.floor((x1 + x2) / 2)
  local cy = math.floor((y1 + y2) / 2)
  local rx = math.floor((x2 - x1) / 2)
  local ry = math.floor((y2 - y1) / 2)
  return Position(cx, cy, a.z), rx, ry
end

local function countPillarsInRect(rect)
  local center, rx, ry = rectCenterAndRadii(rect.fromPos, rect.toPos)
  local specs = Game.getSpectators(center, false, false, rx, rx, ry, ry)
  local count = 0
  for _, cr in ipairs(specs) do
    if cr:isMonster() and PILLAR_NAME_TO_TYPE[cr:getName():lower()] then
      count = count + 1
    end
  end
  return count
end

local function spawnOnePillarInRect(rect)
  if countPillarsInRect(rect) >= maxPillarsPerArea then
    return false
  end

  local pick = PILLARS[math.random(1, #PILLARS)]
  for _ = 1, maxTries do
    local pos = randomPosInRect(rect.fromPos, rect.toPos)
    if isTileSpawnable(pos) then
      local mon = Game.createMonster(pick.name, pos, false, true)
      if mon then
        mon:setNoMove(true)

        local id = mon:getId()
        addEvent(function()
          local m2 = Creature(id)
          if m2 and m2:isMonster() and not m2:isRemoved() then
            m2:remove()
          end
        end, pillarDuration * 1000)

        return true
      end
    end
  end
  return false
end


local THINK_DELAY = 3
local THINK_STORAGE = 900004

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
    spawnOnePillarInRect(AREAS[idx])
    self:setStorageValue(StorageSpawnNext, now + spawnInterval)
  end
end

mType.onAppear = function(monster, creature)
  if monster:getId() ~= creature:getId() then return end
  monster:setStorageValue(StorageSpawnNext, os.time() + firstDelayPillar)
  local idx = areaOfPosition(monster:getPosition())
  if idx then monster:setStorageValue(StorageAreaIndex, idx) end
end

mType.onDisappear = function(monster, creature)
  if monster:getId() ~= creature:getId() then return end
  local idx = monster:getStorageValue(StorageAreaIndex)
  if type(idx) ~= "number" or not AREAS[idx] then return end
  local rect = AREAS[idx]
  local center, rx, ry = rectCenterAndRadii(rect.fromPos, rect.toPos)
  local specs = Game.getSpectators(center, false, false, rx, rx, ry, ry)
  for _, cr in ipairs(specs) do
    if cr:isMonster() and PILLAR_NAME_TO_TYPE[cr:getName():lower()] then
      cr:remove()
    end
  end
end

local BOSS_NAME = "Nyxdrath the Midnight Terror"

local function pillarTypeAdjacentToBoss(boss)
  local p = boss:getPosition()
  local around = {
    Position(p.x + 1, p.y, p.z),
    Position(p.x - 1, p.y, p.z),
    Position(p.x, p.y + 1, p.z),
    Position(p.x, p.y - 1, p.z),
  }
  for _, pos in ipairs(around) do
    local tile = Tile(pos)
    if tile then
      local top = tile:getTopCreature()
      if top and top:isMonster() then
        local t = PILLAR_NAME_TO_TYPE[top:getName():lower()]
        if t then return t end
      end
    end
  end
  return nil
end

local evt = CreatureEvent("nyxdrath_damage")
function evt.onHealthChange(target, source, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
  if not target or not target:isMonster() then
    return primaryDamage, primaryType, secondaryDamage, secondaryType
  end
  if target:getName() ~= BOSS_NAME then
    return primaryDamage, primaryType, secondaryDamage, secondaryType
  end

  local allowedType = pillarTypeAdjacentToBoss(target)
  if not allowedType then
    return 0, primaryType, 0, secondaryType
  end

  local pd = (primaryType == allowedType) and primaryDamage or 0
  local sd = (secondaryType == allowedType) and secondaryDamage or 0
  return pd, primaryType, sd, secondaryType
end
evt:register()

mType.onMove = function(monster, creature, fromPosition, toPosition)
	if monster:getId() == creature:getId() then
	end
end

mType.onSay = function(monster, creature, type, message)
end

mType:register(monster)