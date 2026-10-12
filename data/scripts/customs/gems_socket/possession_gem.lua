PossessionGem = PossessionGem or {}

PossessionGem.gemKey = "possessiongem"
PossessionGem.runtimeState = PossessionGem.runtimeState or {}
PossessionGem.monsterFileIndex = PossessionGem.monsterFileIndex or nil
PossessionGem.attackCache = PossessionGem.attackCache or {}

local function possessionToNumber(value, fallback)
    local number = tonumber(value)
    if number == nil then
        return fallback or 0
    end
    return number
end

local function getPossessionGemData()
    return GemsSocket and GemsSocket.GEMS and GemsSocket.GEMS[PossessionGem.gemKey] or nil
end

local function isPossessionBlockedBoss(monster)
    if type(_G.ShockwaveStone_isBossMonster) == "function" then
        return _G.ShockwaveStone_isBossMonster(monster)
    end

    return monster and type(monster.isBoss) == "function" and monster:isBoss() or false
end

function PossessionGem.isGem(gemKey)
    return gemKey == PossessionGem.gemKey
end

function PossessionGem.getSettings(level)
    local gemData = getPossessionGemData()
    local levelData = nil
    if type(_G.getGemLevelData) == "function" then
        gemData, levelData = _G.getGemLevelData(PossessionGem.gemKey, level or 1)
    elseif type(gemData) == "table" and type(gemData.tiers) == "table" then
        levelData = gemData.tiers[level or 1]
    end

    local gemSettings = type(gemData) == "table" and type(gemData.possession) == "table" and gemData.possession or {}
    local levelSettings = type(levelData) == "table" and type(levelData.possession) == "table" and levelData.possession or {}

    return {
        unlockKills = math.max(1, possessionToNumber(levelSettings.unlockKills, gemSettings.unlockKills or 1000)),
        maxActiveSouls = math.max(1, possessionToNumber(levelSettings.maxActiveSouls, gemSettings.maxActiveSouls or 3)),
        cooldown = math.max(1, possessionToNumber(levelSettings.cooldown, gemSettings.cooldown or 30)),
        damageMin = math.max(0, possessionToNumber(levelSettings.damageMin, gemSettings.damageMin or 120)),
        damageMax = math.max(0, possessionToNumber(levelSettings.damageMax, gemSettings.damageMax or 200)),
        slowDurationMs = math.max(500, possessionToNumber(levelSettings.slowDurationMs, gemSettings.slowDurationMs or 2500)),
        slowPercent = math.max(1, possessionToNumber(levelSettings.slowPercent, gemSettings.slowPercent or 20)),
    }
end

function PossessionGem.getAttributePrefix(socketIndex)
    if socketIndex then
        return string.format("socket_%d_possession_", socketIndex)
    end
    return "possession_"
end

local function normalizeState(state)
    state = type(state) == "table" and state or {}
    state.kills = type(state.kills) == "table" and state.kills or {}
    state.thresholds = type(state.thresholds) == "table" and state.thresholds or {}
    state.active = type(state.active) == "table" and state.active or {}
    return state
end

function PossessionGem.readState(item, socketIndex)
    if not item or not item.isItem or not item:isItem() then
        return nil
    end

    local prefix = PossessionGem.getAttributePrefix(socketIndex)
    local rawState = item:getCustomAttribute(prefix .. "state")
    if type(rawState) ~= "string" or rawState == "" then
        return nil
    end

    local ok, decoded = pcall(function()
        return json.decode(rawState)
    end)
    if not ok or type(decoded) ~= "table" then
        return nil
    end

    return normalizeState(decoded)
end

function PossessionGem.clearState(item, socketIndex)
    if not item or not item.isItem or not item:isItem() then
        return
    end

    item:removeCustomAttribute(PossessionGem.getAttributePrefix(socketIndex) .. "state")
end

function PossessionGem.writeState(item, socketIndex, state)
    if not item or not item.isItem or not item:isItem() then
        return
    end

    PossessionGem.clearState(item, socketIndex)
    state = normalizeState(state)

    local hasData = next(state.kills) or next(state.thresholds) or (#state.active > 0)
    if not hasData then
        return
    end

    local prefix = PossessionGem.getAttributePrefix(socketIndex)
    item:setCustomAttribute(prefix .. "state", json.encode(state))
end

local function removeActiveSoul(activeList, monsterName)
    for index = #activeList, 1, -1 do
        if activeList[index] == monsterName then
            table.remove(activeList, index)
        end
    end
end

local function formatActiveSoulLine(monsterName, kills, unlockKills)
    local soulTier = math.max(1, math.floor((kills or 0) / math.max(1, unlockKills)))
    return string.format("%s T%d (%d)", monsterName, soulTier, kills or 0)
end

function PossessionGem.getCompactProgress(state, level)
    state = normalizeState(state)
    local activeCount = #state.active
    if activeCount <= 0 then
        return "Souls: None"
    end

    local names = {}
    for index, monsterName in ipairs(state.active) do
        if index > 3 then
            break
        end
        names[#names + 1] = tostring(monsterName)
    end

    return "Souls: " .. table.concat(names, ", ")
end

function PossessionGem.buildTooltip(baseTooltip, state, level)
    state = normalizeState(state)
    local settings = PossessionGem.getSettings(level)
    local lines = {}
    local baseLine = tostring(baseTooltip or "")
    if baseLine ~= "" then
        lines[#lines + 1] = baseLine
    end

    if #state.active <= 0 then
        lines[#lines + 1] = string.format("Captured Souls: 0 / %d", settings.maxActiveSouls)
        lines[#lines + 1] = "Souls: None"
        lines[#lines + 1] = string.format("Next Soul: %d / %d kills", 0, settings.unlockKills)
        return table.concat(lines, "\n")
    end

    local names = {}
    for index, monsterName in ipairs(state.active) do
        if index > settings.maxActiveSouls then
            break
        end
        names[#names + 1] = tostring(monsterName)
    end
    lines[#lines + 1] = string.format("Captured Souls: %s", table.concat(names, ", "))
    lines[#lines + 1] = "Souls: " .. table.concat(names, ", ")

    for _, monsterName in ipairs(state.active) do
        lines[#lines + 1] = formatActiveSoulLine(monsterName, possessionToNumber(state.kills[monsterName], 0), settings.unlockKills)
    end

    return table.concat(lines, "\n")
end

function PossessionGem.forEachEquippedSocket(player, callback, bonusCache)
    if not player or type(callback) ~= "function" or type(GemsSocket.EQUIPPED_SOCKET_SLOTS) ~= "table" then
        return
    end

    if bonusCache and type(_G.GemsSocketBonusCache) == "table"
        and type(_G.GemsSocketBonusCache.forEachCachedGemSocket) == "function" then
        _G.GemsSocketBonusCache.forEachCachedGemSocket(bonusCache, PossessionGem.gemKey, callback)
        return
    elseif type(_G.GemsSocket_forEachEquippedGemSocket) == "function" then
        _G.GemsSocket_forEachEquippedGemSocket(player, PossessionGem.gemKey, callback)
        return
    end

    local hasSockets = _G.GemsSocket_hasSockets
    local getSocketCount = _G.GemsSocket_getSocketCount
    local getSocketGemKey = _G.GemsSocket_getSocketGemKey
    if type(hasSockets) ~= "function" or type(getSocketCount) ~= "function" or type(getSocketGemKey) ~= "function" then
        return
    end

    for _, slot in ipairs(GemsSocket.EQUIPPED_SOCKET_SLOTS) do
        local item = player:getSlotItem(slot)
        if item and hasSockets(item) then
            for socketIndex = 1, getSocketCount(item) do
                if PossessionGem.isGem(getSocketGemKey(item, socketIndex)) then
                    callback(item, socketIndex)
                end
            end
        end
    end
end

local function buildXmlMonsterIndex()
    if PossessionGem.monsterFileIndex then
        return PossessionGem.monsterFileIndex
    end

    local index = {}
    local file = io.open("data/monster/monsters.xml", "r")
    if file then
        local content = file:read("*a")
        file:close()
        for monsterName, relativePath in content:gmatch('<monster%s+name="([^"]+)"%s+file="([^"]+)"') do
            index[monsterName] = "data/monster/" .. relativePath
        end
    end

    if type(_G.PossessionMonsterLuaIndex) == "table" then
        for monsterName, relativePath in pairs(_G.PossessionMonsterLuaIndex) do
            if not index[monsterName] then
                index[monsterName] = relativePath
            end
        end
    end

    PossessionGem.monsterFileIndex = index
    return index
end

local XML_COMBAT_TYPES = {
    physical = COMBAT_PHYSICALDAMAGE,
    poison = COMBAT_EARTHDAMAGE,
    earth = COMBAT_EARTHDAMAGE,
    fire = COMBAT_FIREDAMAGE,
    energy = COMBAT_ENERGYDAMAGE,
    ice = COMBAT_ICEDAMAGE,
    holy = COMBAT_HOLYDAMAGE,
    death = COMBAT_DEATHDAMAGE,
    lifedrain = COMBAT_LIFEDRAIN,
    manadrain = COMBAT_MANADRAIN,
    drown = COMBAT_DROWNDAMAGE,
}

local MAGIC_EFFECT_BY_NAME = {
    greenspark = CONST_ME_HITBYPOISON,
    greenbubble = CONST_ME_GREEN_RINGS,
    poison = CONST_ME_POISONAREA,
    fire = CONST_ME_FIREAREA,
    energy = CONST_ME_ENERGYAREA,
    explosion = CONST_ME_EXPLOSIONAREA,
    hitbyfire = CONST_ME_HITBYFIRE,
    hitbypoison = CONST_ME_HITBYPOISON,
    magicblue = CONST_ME_MAGIC_BLUE,
    magicred = CONST_ME_MAGIC_RED,
    purpleenergy = CONST_ME_PURPLEENERGY,
    holydamage = CONST_ME_HOLYDAMAGE,
    mortarea = CONST_ME_MORTAREA,
    icetornado = CONST_ME_ICETORNADO,
    loseenergy = CONST_ME_LOSEENERGY,
}

local DISTANCE_EFFECT_BY_NAME = {
    poison = CONST_ANI_POISON,
    fire = CONST_ANI_FIRE,
    energy = CONST_ANI_ENERGY,
    smallstone = CONST_ANI_SMALLSTONE,
    death = CONST_ANI_SUDDENDEATH,
    infernalbolt = CONST_ANI_INFERNALBOLT,
    snowball = CONST_ANI_SNOWBALL,
    spear = CONST_ANI_SPEAR,
}

local function lookupMagicEffect(value)
    if type(value) == "number" then
        return value
    end
    if type(value) ~= "string" or value == "" then
        return nil
    end

    local numeric = tonumber(value)
    if numeric then
        return numeric
    end

    return MAGIC_EFFECT_BY_NAME[value:lower()]
end

local function lookupDistanceEffect(value)
    if type(value) == "number" then
        return value
    end
    if type(value) ~= "string" or value == "" then
        return nil
    end

    local numeric = tonumber(value)
    if numeric then
        return numeric
    end

    return DISTANCE_EFFECT_BY_NAME[value:lower()]
end

local function parseKeyValueTable(entryText)
    local parsed = {}
    for key, rawValue in entryText:gmatch('([%a_][%w_]*)%s*=%s*([^,}]+)') do
        rawValue = rawValue:gsub("^%s+", ""):gsub("%s+$", "")
        if rawValue:sub(1, 1) == '"' or rawValue:sub(1, 1) == "'" then
            parsed[key] = rawValue:sub(2, -2)
        elseif rawValue == "true" then
            parsed[key] = true
        elseif rawValue == "false" then
            parsed[key] = false
        else
            local numeric = tonumber(rawValue)
            if numeric ~= nil then
                parsed[key] = numeric
            else
                parsed[key] = _G[rawValue] or rawValue
            end
        end
    end
    return parsed
end

local function normalizeParsedAttack(parsed)
    local attackName = type(parsed.name) == "string" and parsed.name:lower() or nil
    if parsed.script or not attackName then
        return nil
    end

    local attack = {
        combatType = COMBAT_PHYSICALDAMAGE,
        effect = lookupMagicEffect(parsed.effect or parsed.areaEffect),
        shootEffect = lookupDistanceEffect(parsed.shootEffect),
        target = parsed.target == true or possessionToNumber(parsed.target, 0) == 1,
        radius = math.max(0, possessionToNumber(parsed.radius, 0)),
        length = math.max(0, possessionToNumber(parsed.length, 0)),
        spread = math.max(0, possessionToNumber(parsed.spread, 0)),
        range = math.max(0, possessionToNumber(parsed.range, 0)),
        slowDuration = math.max(0, possessionToNumber(parsed.duration, 0)),
        slowSpeed = possessionToNumber(parsed.speed, 0),
        rawName = attackName,
    }

    if attackName == "melee" then
        attack.kind = "melee"
        attack.combatType = COMBAT_PHYSICALDAMAGE
    elseif attackName == "speed" then
        attack.kind = attack.length > 0 and "beam" or (attack.radius > 0 and "radius" or (attack.range > 0 or attack.target) and "projectile" or nil)
        attack.condition = "slow"
        attack.combatType = COMBAT_PHYSICALDAMAGE
    elseif attackName == "combat" then
        attack.kind = attack.length > 0 and "beam" or (attack.radius > 0 and "radius" or (attack.range > 0 or attack.target) and "projectile" or nil)
        attack.combatType = parsed.type or COMBAT_PHYSICALDAMAGE
    elseif XML_COMBAT_TYPES[attackName] then
        attack.kind = attack.length > 0 and "beam" or (attack.radius > 0 and "radius" or (attack.range > 0 or attack.target) and "projectile" or nil)
        attack.combatType = XML_COMBAT_TYPES[attackName]
    else
        return nil
    end

    if not attack.kind then
        return nil
    end

    if attack.kind == "projectile" and attack.range <= 0 then
        attack.range = 7
    end

    return attack
end

local function parseXmlAttacks(content)
    local attacks = {}

    for attackTag, inner in content:gmatch("<attack%s+([^>/]-)%s*>(.-)</attack>") do
        local parsed = {}
        for key, value in attackTag:gmatch('([%w_]+)="([^"]*)"') do
            parsed[key] = value
        end
        for attrKey, attrValue in inner:gmatch('<attribute%s+key="([^"]+)"%s+value="([^"]+)"%s*/>') do
            parsed[attrKey] = attrValue
        end

        local normalized = normalizeParsedAttack(parsed)
        if normalized then
            attacks[#attacks + 1] = normalized
        end
    end

    for attackTag in content:gmatch("<attack%s+([^>/]-)%s*/>") do
        local parsed = {}
        for key, value in attackTag:gmatch('([%w_]+)="([^"]*)"') do
            parsed[key] = value
        end
        local normalized = normalizeParsedAttack(parsed)
        if normalized then
            attacks[#attacks + 1] = normalized
        end
    end

    return attacks
end

local function parseLuaAttacks(content)
    local attacks = {}
    local blockStart = content:find("monster%.attacks%s*=%s*{")
    if not blockStart then
        return attacks
    end

    local startBrace = content:find("{", blockStart)
    if not startBrace then
        return attacks
    end

    local depth = 0
    local blockEnd = nil
    for index = startBrace, #content do
        local char = content:sub(index, index)
        if char == "{" then
            depth = depth + 1
        elseif char == "}" then
            depth = depth - 1
            if depth == 0 then
                blockEnd = index
                break
            end
        end
    end

    if not blockEnd then
        return attacks
    end

    local block = content:sub(startBrace + 1, blockEnd - 1)
    local entryDepth = 0
    local entryStart = nil
    for index = 1, #block do
        local char = block:sub(index, index)
        if char == "{" then
            entryDepth = entryDepth + 1
            if entryDepth == 1 then
                entryStart = index
            end
        elseif char == "}" then
            if entryDepth == 1 and entryStart then
                local entryText = block:sub(entryStart + 1, index - 1)
                local normalized = normalizeParsedAttack(parseKeyValueTable(entryText))
                if normalized then
                    attacks[#attacks + 1] = normalized
                end
                entryStart = nil
            end
            entryDepth = math.max(0, entryDepth - 1)
        end
    end

    return attacks
end

function PossessionGem.getCompatibleAttacks(monsterName)
    if type(monsterName) ~= "string" or monsterName == "" then
        return {}
    end

    if PossessionGem.attackCache[monsterName] ~= nil then
        return PossessionGem.attackCache[monsterName]
    end

    local monsterFiles = buildXmlMonsterIndex()
    local monsterFile = monsterFiles[monsterName]
    if not monsterFile then
        PossessionGem.attackCache[monsterName] = {}
        return PossessionGem.attackCache[monsterName]
    end

    local file = io.open(monsterFile, "r")
    if not file then
        PossessionGem.attackCache[monsterName] = {}
        return PossessionGem.attackCache[monsterName]
    end

    local content = file:read("*a")
    file:close()

    local attacks = monsterFile:sub(-4):lower() == ".xml" and parseXmlAttacks(content) or parseLuaAttacks(content)
    PossessionGem.attackCache[monsterName] = attacks or {}
    return PossessionGem.attackCache[monsterName]
end

local function getReverseDirection(direction)
    if direction == NORTH then
        return SOUTH
    elseif direction == SOUTH then
        return NORTH
    elseif direction == EAST then
        return WEST
    elseif direction == WEST then
        return EAST
    end
    return SOUTH
end

local function getDirectionBetweenPositions(fromPosition, toPosition)
    local dx = (toPosition.x or 0) - (fromPosition.x or 0)
    local dy = (toPosition.y or 0) - (fromPosition.y or 0)
    if math.abs(dx) > math.abs(dy) then
        return dx >= 0 and EAST or WEST
    end
    return dy >= 0 and SOUTH or NORTH
end

local function makePosition(x, y, z)
    return Position(x, y, z)
end

local function positionKey(position)
    return string.format("%d:%d:%d", position.x, position.y, position.z)
end

local function getAttackPositions(player, target, attack)
    local positions = {}
    local origin = player:getPosition()
    if attack.kind == "radius" then
        local center = attack.target and target:getPosition() or origin
        local radius = math.max(1, attack.radius)
        if radius == 3 then
            radius = 2
        elseif radius >= 4 then
            radius = 3
        end
        radius = math.min(radius, 3)
        for x = center.x - radius, center.x + radius do
            for y = center.y - radius, center.y + radius do
                local dx = x - center.x
                local dy = y - center.y
                if (dx * dx) + (dy * dy) <= radius * radius then
                    positions[#positions + 1] = makePosition(x, y, center.z)
                end
            end
        end
        return positions, center
    elseif attack.kind == "beam" then
        local direction = getDirectionBetweenPositions(origin, target:getPosition())
        local forward = Position.directionOffset[direction] or { x = 0, y = 1 }
        local side = (direction == NORTH or direction == SOUTH) and { x = 1, y = 0 } or { x = 0, y = 1 }
        local copiedSpread = math.min(math.max(0, attack.spread), 1)
        local copiedLength = math.min(math.max(1, attack.length), 4)
        for step = 1, copiedLength do
            local centerX = origin.x + forward.x * step
            local centerY = origin.y + forward.y * step
            for offset = -copiedSpread, copiedSpread do
                positions[#positions + 1] = makePosition(centerX + side.x * offset, centerY + side.y * offset, origin.z)
            end
        end
        return positions, origin
    elseif attack.kind == "projectile" then
        return { target:getPosition() }, target:getPosition()
    elseif attack.kind == "melee" then
        return { target:getPosition() }, target:getPosition()
    end

    return positions, origin
end

local function isValidPvETarget(creature)
    return creature and creature:isMonster() and not creature:getMaster()
end

local function collectTargetsForAttack(player, target, attack, positions)
    if not player or not target then
        return {}
    end

    if attack.kind == "projectile" then
        if not isValidPvETarget(target) then
            return {}
        end

        local range = math.max(1, attack.range)
        local playerPos = player:getPosition()
        local targetPos = target:getPosition()
        if math.max(math.abs(playerPos.x - targetPos.x), math.abs(playerPos.y - targetPos.y)) > range then
            return {}
        end
        return { target }
    elseif attack.kind == "melee" then
        if not isValidPvETarget(target) then
            return {}
        end

        local playerPos = player:getPosition()
        local targetPos = target:getPosition()
        local adjacent = math.max(math.abs(playerPos.x - targetPos.x), math.abs(playerPos.y - targetPos.y)) <= 1
        if not adjacent then
            return {}
        end

        local behindDirection = getReverseDirection(target:getDirection())
        local expectedBehind = makePosition(targetPos.x, targetPos.y, targetPos.z)
        expectedBehind:getNextPosition(behindDirection)
        if expectedBehind.x ~= playerPos.x or expectedBehind.y ~= playerPos.y or expectedBehind.z ~= playerPos.z then
            return {}
        end

        return { target }
    end

    local positionLookup = {}
    local minX, maxX, minY, maxY = player:getPosition().x, player:getPosition().x, player:getPosition().y, player:getPosition().y
    local z = player:getPosition().z
    for _, pos in ipairs(positions) do
        positionLookup[positionKey(pos)] = true
        minX = math.min(minX, pos.x)
        maxX = math.max(maxX, pos.x)
        minY = math.min(minY, pos.y)
        maxY = math.max(maxY, pos.y)
        z = pos.z
    end

    -- Called only after an equipped Possession attack passes state and cooldown checks.
    local spectators = Game.getSpectators(makePosition(math.floor((minX + maxX) / 2), math.floor((minY + maxY) / 2), z), false, false, maxX - minX, maxX - minX, maxY - minY, maxY - minY)
    local targets = {}
    for _, creature in ipairs(spectators) do
        if isValidPvETarget(creature) then
            local pos = creature:getPosition()
            if positionLookup[positionKey(pos)] then
                targets[#targets + 1] = creature
            end
        end
    end
    return targets
end

local function applySlowCondition(target, settings)
    if not target or not target:isMonster() then
        return
    end

    local condition = Condition(CONDITION_PARALYZE)
    condition:setParameter(CONDITION_PARAM_TICKS, settings.slowDurationMs)
    condition:setFormula(-settings.slowPercent / 100, 0, -settings.slowPercent / 100, 0)
    target:addCondition(condition)
end

function PossessionGem.tryCast(player, target, item, socketIndex)
    if not player or not player:isPlayer() or not target or not target:isMonster() then
        return false
    end
    if target:getMaster() then
        return false
    end

    local playerId = player:getId()
    local level = type(_G.GemsSocket_getSocketGemLevel) == "function" and _G.GemsSocket_getSocketGemLevel(item, socketIndex) or 1
    local settings = PossessionGem.getSettings(level)
    local runtime = PossessionGem.runtimeState[playerId] or {}
    PossessionGem.runtimeState[playerId] = runtime
    local now = os.time()
    if now < possessionToNumber(runtime.cooldownUntil, 0) then
        return false
    end

    local state = PossessionGem.readState(item, socketIndex)
    if not state or #state.active <= 0 then
        return false
    end

    local available = {}
    for _, monsterName in ipairs(state.active) do
        for _, attack in ipairs(PossessionGem.getCompatibleAttacks(monsterName)) do
            available[#available + 1] = {
                monsterName = monsterName,
                attack = attack,
            }
        end
    end

    if #available <= 0 then
        return false
    end

    local selected = available[math.random(#available)]
    local attack = selected.attack
    local positions, effectOrigin = getAttackPositions(player, target, attack)
    local targets = collectTargetsForAttack(player, target, attack, positions)
    if #targets <= 0 then
        return false
    end

    local minDamage = math.max(0, settings.damageMin)
    local maxDamage = math.max(minDamage, settings.damageMax)
    if attack.shootEffect and target then
        player:getPosition():sendDistanceEffect(target:getPosition(), attack.shootEffect)
    end

    local displayed = {}
    for _, pos in ipairs(positions) do
        local key = positionKey(pos)
        if not displayed[key] then
            displayed[key] = true
            if attack.effect then
                pos:sendMagicEffect(attack.effect)
            end
        end
    end

    for _, creature in ipairs(targets) do
        doTargetCombat(player, creature, attack.combatType or COMBAT_PHYSICALDAMAGE, -minDamage, -maxDamage, attack.effect or CONST_ME_NONE)
        if attack.condition == "slow" then
            applySlowCondition(creature, settings)
        end
    end

    runtime.cooldownUntil = now + settings.cooldown
    return true
end

function PossessionGem.recordKill(player, item, socketIndex, monster)
    if not player or not item or not monster or not monster:isMonster() or monster:getMaster() or isPossessionBlockedBoss(monster) then
        return false
    end

    local monsterName = monster:getName()
    if type(monsterName) ~= "string" or monsterName == "" then
        return false
    end

    local settings = PossessionGem.getSettings(type(_G.GemsSocket_getSocketGemLevel) == "function" and _G.GemsSocket_getSocketGemLevel(item, socketIndex) or 1)
    local state = normalizeState(PossessionGem.readState(item, socketIndex))
    state.kills[monsterName] = possessionToNumber(state.kills[monsterName], 0) + 1

    local thresholdCount = math.floor(state.kills[monsterName] / settings.unlockKills)
    local previousThresholdCount = math.max(0, possessionToNumber(state.thresholds[monsterName], 0))
    if thresholdCount > previousThresholdCount then
        state.thresholds[monsterName] = thresholdCount
        removeActiveSoul(state.active, monsterName)
        state.active[#state.active + 1] = monsterName
        while #state.active > settings.maxActiveSouls do
            table.remove(state.active, 1)
        end
    end

    PossessionGem.writeState(item, socketIndex, state)
    if type(_G.setSocketGemDisplayData) == "function" then
        _G.setSocketGemDisplayData(item, socketIndex, getPossessionGemData())
    end
    if type(_G.GemsSocket_refreshSocketDisplay) == "function" then
        _G.GemsSocket_refreshSocketDisplay(item)
    elseif type(_G.refreshSocketItem) == "function" then
        _G.refreshSocketItem(item)
    end
    return true
end
