AbattoirGem = AbattoirGem or {}

AbattoirGem.gemKey = "abattoirgem"
AbattoirGem.runtime = AbattoirGem.runtime or {}
AbattoirGem.spawnOwnerByMonsterId = AbattoirGem.spawnOwnerByMonsterId or {}

AbattoirGem.tiers = {
    [1] = {
        name = "Blood Warmed",
        minHeat = 10,
        ambushChance = 2,
        bossChance = 0,
        ambushCount = 2,
        monsters = { "Hydra", "Dragon", "Dragon Lord", "Serpent Spawn", "Medusa", "Sea Serpent", "Behemoth", "Lizard Chosen", "Lizard Dragon Priest", "Frazzlemaw" },
        bosses = {},
    },
    [2] = {
        name = "Butcher's Notice",
        minHeat = 25,
        ambushChance = 3,
        bossChance = 1,
        ambushCount = 2,
        monsters = { "Hellspawn", "Demon", "Grim Reaper", "Destroyer", "Dark Torturer", "Fury", "Minishabaal", "Juggernaut", "Hand of Cursed Fate", "Undead Dragon", "Ghastly Dragon", "Guzzlemaw", "Silencer", "Retching Horror", "Choking Fear" },
        bosses = { "Hellgorak" },
    },
    [3] = {
        name = "Red Work",
        minHeat = 40,
        ambushChance = 4,
        bossChance = 1,
        ambushCount = 3,
        monsters = { "Falcon Paladin", "Falcon Knight", "Cobra Assassin", "Cobra Vizier", "Cobra Scout", "Demon of the Depths", "Brontosaurus", "Black Dragon", "Alpha Demon", "Aberration of the Depths", "Butcher Ogre", "Giant Hornet", "Netheria Dragon", "Reflect Spider", "Rhino of the Depths", "Ruthless Spider", "Skullcrusher Demon" },
        bosses = { "Hellgorak", "Orshabaal" },
    },
    [4] = {
        name = "Execution Hour",
        minHeat = 60,
        ambushChance = 5,
        bossChance = 2,
        ambushCount = 3,
        monsters = { "Brain Squid", "Energetic Book", "Floating Savant", "Energuardian of Tales", "Burning Book", "Animated Feather", "Guardian of Tales", "Icecold Book", "Knowledge Elemental", "Rage Squid", "Squid Warden" },
        bosses = { "Orshabaal", "Morgaroth", "Ghazbaran", "Mawhawk", "Apocalypse", "Zulazza the corruptor" },
    },
    [5] = {
        name = "Infernal Audit",
        minHeat = 80,
        ambushChance = 6,
        bossChance = 2,
        ambushCount = 4,
        monsters = { "Brachiodemon", "Branchy Crawler", "Bony Sea Devil", "Capricious Phantom", "Cloak of Terror", "Courage Leech", "Distorted Phantom", "Druid's Apparition", "Hazardous Phantom", "Illusionist's Apparition", "Infernal Demon", "Infernal Phantom", "Knight's Apparition", "Many Faces", "Monk's Apparition", "Mould Phantom", "Rotten Golem", "Paladin's Apparition", "Sorcerer's Apparition", "Turbulent Elemental", "Vibrant Phantom" },
        bosses = { "Zulazza the corruptor", "Mawhawk", "Orshabaal", "Morgaroth", "Ghazbaran", "Goshnar's Malice", "Goshnar's Hatred", "Gnomevil"},
    },
    [6] = {
        name = "Abattoir Open",
        minHeat = 100,
        ambushChance = 8,
        bossChance = 3,
        ambushCount = 5,
        monsters = { "Converter", "Darklight Construct", "Darklight Emitter", "Darklight Matter", "Darklight Source", "Darklight Striker", "Elder Bloodjaw", "Meandering Mushroom", "Mycobiontic Beetle", "Oozing Carcass", "Oozing Corpus", "Rotten Man-Maggot", "Sopping Carcass", "Sopping Corpus", "Walking Pillar", "Wandering Pillar", "Hand of Cursed Fate", "Capricious Phantom", "Turbulent Elemental", "Juggernaut", "Many Faces", "Burning Book", "Guardian of Tales", "Squid Warden", "Cursed Voidcaller", "Dreadhorn Ravager", "Necroflame Idol", "Spineback Devourer", "Eldritch Devourer", "Venom Ooze", "Void Ooze" },
        bosses = {"Goshnar's Malice", "Goshnar's Hatred", "Gnomevil", "Deathstrike", "Vemiath", "Chagorz", "Murcion", "Ichgahal", "Icebound Thryssan", "Vladrukh", "Mazzinor", "Lokathmor", "Plagirath" },
    },
}

local function abattoirToNumber(value, fallback)
    local number = tonumber(value)
    if number == nil then
        return fallback or 0
    end
    return number
end

local function getAbattoirGemData()
    return GemsSocket and GemsSocket.GEMS and GemsSocket.GEMS[AbattoirGem.gemKey] or nil
end

local function getSpecialConfig()
    return (GemsSocket and GemsSocket.SPECIALS and GemsSocket.SPECIALS.abattoir) or {}
end

local function getMessages()
    local special = getSpecialConfig()
    return type(special.messages) == "table" and special.messages or {}
end

local function getGemLevelBonus(level, key)
    local gemData = getAbattoirGemData()
    if type(gemData) ~= "table" then
        return 0
    end

    local tierData = type(gemData.tiers) == "table" and gemData.tiers[math.max(1, abattoirToNumber(level, 1))] or nil
    local tierBonuses = type(tierData) == "table" and type(tierData.bonuses) == "table" and tierData.bonuses or nil
    if tierBonuses and tierBonuses[key] ~= nil then
        return abattoirToNumber(tierBonuses[key], 0)
    end

    local baseBonuses = type(gemData.bonuses) == "table" and gemData.bonuses or nil
    return abattoirToNumber(baseBonuses and baseBonuses[key], 0)
end

local function getEquippedAbattoirBonus(player, key, level)
    if player and type(_G.GemsSocket_getEquippedSocketBonusTotal) == "function" then
        local value = abattoirToNumber(_G.GemsSocket_getEquippedSocketBonusTotal(player, key), 0)
        if value > 0 then
            return value
        end
    end
    return getGemLevelBonus(level, key)
end

local function getPositionData(position)
    if not position then
        return nil
    end
    return { x = position.x, y = position.y, z = position.z }
end

local function getAnchorPosition(state)
    if type(state) ~= "table" then
        return nil
    end

    local x = tonumber(state.anchorX)
    local y = tonumber(state.anchorY)
    local z = tonumber(state.anchorZ)
    if not x or not y or not z then
        return nil
    end
    return Position(x, y, z)
end

local function isPlayerInProtectionZone(player)
    local tile = player and Tile(player:getPosition())
    return tile and tile:hasFlag(TILESTATE_PROTECTIONZONE)
end

local function rollPercent(chance)
    chance = math.max(0, abattoirToNumber(chance, 0))
    if chance <= 0 then
        return false
    end
    return math.random(10000) <= math.min(10000, math.floor(chance * 100))
end

local function getSpawnPosition(anchorPosition)
    local special = getSpecialConfig()
    if type(_G.GemsSocket_findNearbySpawnPosition) == "function" then
        return _G.GemsSocket_findNearbySpawnPosition(anchorPosition, special.spawnSearchMinRange or 1, special.spawnSearchMaxRange or 4)
    end
    return nil
end

local function chooseMonsterName(names)
    if type(names) ~= "table" or #names <= 0 then
        return nil
    end

    local startIndex = math.random(#names)
    for offset = 0, #names - 1 do
        local name = names[((startIndex + offset - 1) % #names) + 1]
        if type(name) == "string" and name ~= "" then
            return name
        end
    end
    return nil
end

local function removeSpawnId(runtime, monsterId)
    if type(runtime) ~= "table" or type(runtime.spawnedIds) ~= "table" then
        return
    end

    for index = #runtime.spawnedIds, 1, -1 do
        if runtime.spawnedIds[index] == monsterId then
            table.remove(runtime.spawnedIds, index)
        end
    end
end

local function hasLiveSpawns(runtime)
    if type(runtime) ~= "table" or type(runtime.spawnedIds) ~= "table" then
        return false
    end

    for _, monsterId in ipairs(runtime.spawnedIds) do
        if Monster(monsterId) then
            return true
        end
    end
    return false
end

function AbattoirGem.isGem(gemKey)
    return gemKey == AbattoirGem.gemKey
end

function AbattoirGem.getAttributePrefix(socketIndex)
    if socketIndex then
        return string.format("socket_%d_abattoir_", socketIndex)
    end
    return "abattoir_"
end

function AbattoirGem.readState(item, socketIndex)
    if not item or not item.isItem or not item:isItem() then
        return nil
    end

    local prefix = AbattoirGem.getAttributePrefix(socketIndex)
    local chain = math.max(0, abattoirToNumber(item:getCustomAttribute(prefix .. "chain"), 0))
    local heat = math.max(0, abattoirToNumber(item:getCustomAttribute(prefix .. "heat"), 0))
    if chain <= 0 and heat <= 0 then
        return nil
    end

    return {
        chain = chain,
        heat = heat,
        heatTier = math.max(0, abattoirToNumber(item:getCustomAttribute(prefix .. "heat_tier"), 0)),
        lastKillTime = math.max(0, abattoirToNumber(item:getCustomAttribute(prefix .. "last_kill_time"), 0)),
        anchorX = item:getCustomAttribute(prefix .. "anchor_x"),
        anchorY = item:getCustomAttribute(prefix .. "anchor_y"),
        anchorZ = item:getCustomAttribute(prefix .. "anchor_z"),
        activeBossId = math.max(0, abattoirToNumber(item:getCustomAttribute(prefix .. "active_boss_id"), 0)),
    }
end

function AbattoirGem.clearState(item, socketIndex)
    if not item or not item.isItem or not item:isItem() then
        return
    end

    local prefix = AbattoirGem.getAttributePrefix(socketIndex)
    item:removeCustomAttribute(prefix .. "chain")
    item:removeCustomAttribute(prefix .. "heat")
    item:removeCustomAttribute(prefix .. "heat_tier")
    item:removeCustomAttribute(prefix .. "last_kill_time")
    item:removeCustomAttribute(prefix .. "anchor_x")
    item:removeCustomAttribute(prefix .. "anchor_y")
    item:removeCustomAttribute(prefix .. "anchor_z")
    item:removeCustomAttribute(prefix .. "active_boss_id")
end

function AbattoirGem.writeState(item, socketIndex, state)
    if not item or not item.isItem or not item:isItem() then
        return
    end

    AbattoirGem.clearState(item, socketIndex)
    if type(state) ~= "table" then
        return
    end

    local chain = math.max(0, abattoirToNumber(state.chain, 0))
    local heat = math.max(0, abattoirToNumber(state.heat, 0))
    if chain <= 0 and heat <= 0 then
        return
    end

    local prefix = AbattoirGem.getAttributePrefix(socketIndex)
    item:setCustomAttribute(prefix .. "chain", chain)
    item:setCustomAttribute(prefix .. "heat", heat)
    item:setCustomAttribute(prefix .. "heat_tier", math.max(0, abattoirToNumber(state.heatTier, 0)))
    item:setCustomAttribute(prefix .. "last_kill_time", math.max(0, abattoirToNumber(state.lastKillTime, os.time())))
    if tonumber(state.anchorX) and tonumber(state.anchorY) and tonumber(state.anchorZ) then
        item:setCustomAttribute(prefix .. "anchor_x", tonumber(state.anchorX))
        item:setCustomAttribute(prefix .. "anchor_y", tonumber(state.anchorY))
        item:setCustomAttribute(prefix .. "anchor_z", tonumber(state.anchorZ))
    end
    if abattoirToNumber(state.activeBossId, 0) > 0 then
        item:setCustomAttribute(prefix .. "active_boss_id", math.max(0, abattoirToNumber(state.activeBossId, 0)))
    end
end

function AbattoirGem.getCompactProgress(state)
    local chain = math.max(0, abattoirToNumber(state and state.chain, 0))
    local heat = math.max(0, abattoirToNumber(state and state.heat, 0))
    local _, tierIndex = AbattoirGem.getTierForHeat(heat)
    if tierIndex > 0 then
        return string.format("Chain: %d  Heat: %d%%  T%d", math.floor(chain), math.floor(heat), tierIndex)
    end
    return string.format("Chain: %d  Heat: %d%%", math.floor(chain), math.floor(heat))
end

function AbattoirGem.getTierForHeat(heat)
    heat = math.max(0, abattoirToNumber(heat, 0))
    local selected = nil
    local selectedIndex = 0
    for index, tier in ipairs(AbattoirGem.tiers) do
        if heat >= math.max(0, abattoirToNumber(tier.minHeat, 0)) then
            selected = tier
            selectedIndex = index
        end
    end
    return selected, selectedIndex
end

function AbattoirGem.buildTooltip(baseTooltip, state, level)
    local lines = {}
    local baseLine = tostring(baseTooltip or "")
    if baseLine ~= "" then
        lines[#lines + 1] = baseLine
    end

    local chain = math.max(0, abattoirToNumber(state and state.chain, 0))
    local heat = math.max(0, abattoirToNumber(state and state.heat, 0))
    local tier, tierIndex = AbattoirGem.getTierForHeat(heat)
    lines[#lines + 1] = string.format("Kill Chain: %d", math.floor(chain))
    lines[#lines + 1] = string.format("Slaughter Heat: %d%%", math.floor(heat))
    if tier and tierIndex > 0 then
        local ambushChance = abattoirToNumber(tier.ambushChance, 0) + getGemLevelBonus(level, "socket_abattoir_ambush_bonus")
        local bossChance = abattoirToNumber(tier.bossChance, 0) + getGemLevelBonus(level, "socket_abattoir_boss_bonus")
        lines[#lines + 1] = string.format("Heat Tier %d: %s", tierIndex, tier.name or "Unknown")
        lines[#lines + 1] = string.format("Ambush: %s%% | Executioner: %s%%", tostring(ambushChance), tostring(bossChance))
    else
        lines[#lines + 1] = "Heat Tier: Dormant"
    end
    lines[#lines + 1] = "Chain resets on death, logout, protection zone, idle, or leaving an active Abattoir event."
    return table.concat(lines, "\n")
end

function AbattoirGem.forEachEquippedSocket(player, callback)
    if not player or type(callback) ~= "function" or type(GemsSocket.EQUIPPED_SOCKET_SLOTS) ~= "table" then
        return
    end

    if type(_G.GemsSocket_forEachEquippedGemSocket) == "function" then
        _G.GemsSocket_forEachEquippedGemSocket(player, AbattoirGem.gemKey, callback)
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
                if AbattoirGem.isGem(getSocketGemKey(item, socketIndex)) then
                    callback(item, socketIndex)
                end
            end
        end
    end
end

function AbattoirGem.findEquippedSocket(player)
    local foundItem = nil
    local foundSocketIndex = nil
    local foundState = nil
    AbattoirGem.forEachEquippedSocket(player, function(item, socketIndex)
        if not foundItem then
            foundItem = item
            foundSocketIndex = socketIndex
            foundState = AbattoirGem.readState(item, socketIndex) or {}
        end
    end)
    return foundItem, foundSocketIndex, foundState
end

function AbattoirGem.refreshSocket(item, socketIndex)
    if type(_G.setSocketGemDisplayData) == "function" then
        _G.setSocketGemDisplayData(item, socketIndex, getAbattoirGemData())
    end
    if type(_G.GemsSocket_refreshSocketDisplay) == "function" then
        _G.GemsSocket_refreshSocketDisplay(item)
    elseif type(_G.refreshSocketItem) == "function" then
        _G.refreshSocketItem(item)
    end
end

function AbattoirGem.cleanupSpawns(playerId)
    local runtime = AbattoirGem.runtime[playerId]
    if not runtime or type(runtime.spawnedIds) ~= "table" then
        return
    end

    for _, monsterId in ipairs(runtime.spawnedIds) do
        AbattoirGem.spawnOwnerByMonsterId[monsterId] = nil
        local monster = Monster(monsterId)
        if monster then
            monster:remove()
        end
    end
    runtime.spawnedIds = {}
    runtime.anchor = nil
end

function AbattoirGem.reset(player, reason)
    if not player or not player:isPlayer() then
        return false
    end

    local playerId = player:getId()
    local item, socketIndex, state = AbattoirGem.findEquippedSocket(player)
    if item and socketIndex then
        AbattoirGem.clearState(item, socketIndex)
        AbattoirGem.refreshSocket(item, socketIndex)
    end

    if getSpecialConfig().removeSpawnsOnReset ~= false then
        AbattoirGem.cleanupSpawns(playerId)
    end

    local runtime = AbattoirGem.runtime[playerId]
    if runtime then
        runtime.token = math.max(1, abattoirToNumber(runtime.token, 0)) + 1
    end
    AbattoirGem.runtime[playerId] = nil

    if reason and state and (abattoirToNumber(state.chain, 0) > 0 or abattoirToNumber(state.heat, 0) > 0) then
        local messages = getMessages()
        player:sendTextMessage(MESSAGE_STATUS_WARNING, messages.reset or "Your Abattoir chain has been lost.")
        local effect = getSpecialConfig().resetEffect or CONST_ME_POFF
        player:getPosition():sendMagicEffect(effect)
    end
    return true
end

function AbattoirGem.getChainGain(player, monster, level)
    if not monster or not monster:isMonster() then
        return 0
    end

    local maxHealth = math.max(0, abattoirToNumber(monster:getMaxHealth(), 0))
    local special = getSpecialConfig()
    if maxHealth < math.max(1, abattoirToNumber(special.minMonsterHealth, 100)) then
        return 0
    end

    local baseGain = 0
    for _, range in ipairs(type(special.chainByHealth) == "table" and special.chainByHealth or {}) do
        local minHealth = math.max(0, abattoirToNumber(range.min, 0))
        local maxRangeHealth = math.max(minHealth, abattoirToNumber(range.max, minHealth))
        if maxHealth >= minHealth and maxHealth <= maxRangeHealth then
            baseGain = math.max(0, abattoirToNumber(range.chain, 0))
            break
        end
    end

    if baseGain <= 0 then
        return 0
    end

    local bonus = math.max(0, getEquippedAbattoirBonus(player, "socket_abattoir_chain_bonus", level))
    return math.max(1, baseGain * (1 + (bonus / 100)))
end

function AbattoirGem.updateHeat(state)
    local special = getSpecialConfig()
    local maxHeat = math.max(1, abattoirToNumber(special.maxHeat, 100))
    state.heat = math.min(maxHeat, math.floor(math.max(0, abattoirToNumber(state.chain, 0)) * math.max(0.01, abattoirToNumber(special.heatPerChain, 0.2))))
    local _, tierIndex = AbattoirGem.getTierForHeat(state.heat)
    state.heatTier = tierIndex
end

function AbattoirGem.getRuntime(playerId)
    local runtime = AbattoirGem.runtime[playerId]
    if not runtime then
        runtime = {
            token = 0,
            spawnedIds = {},
        }
        AbattoirGem.runtime[playerId] = runtime
    end
    runtime.spawnedIds = runtime.spawnedIds or {}
    return runtime
end

function AbattoirGem.monitor(playerId, token)
    local player = Player(playerId)
    if not player then
        AbattoirGem.cleanupSpawns(playerId)
        AbattoirGem.runtime[playerId] = nil
        return
    end

    local runtime = AbattoirGem.runtime[playerId]
    if not runtime or runtime.token ~= token then
        return
    end

    local item, socketIndex, state = AbattoirGem.findEquippedSocket(player)
    if not item or not socketIndex or type(state) ~= "table" then
        AbattoirGem.cleanupSpawns(playerId)
        AbattoirGem.runtime[playerId] = nil
        return
    end

    local special = getSpecialConfig()
    if special.resetOnProtectionZone ~= false and isPlayerInProtectionZone(player) then
        AbattoirGem.reset(player, "protection_zone")
        return
    end

    local now = os.time()
    local idleResetSeconds = math.max(10, abattoirToNumber(special.idleResetSeconds, 90))
    if now - math.max(0, abattoirToNumber(state.lastKillTime, now)) >= idleResetSeconds then
        AbattoirGem.reset(player, "idle")
        return
    end

    local anchorPosition = getAnchorPosition(state) or (runtime.anchor and Position(runtime.anchor.x, runtime.anchor.y, runtime.anchor.z))
    if anchorPosition and hasLiveSpawns(runtime) then
        local playerPosition = player:getPosition()
        local leashRadius = math.max(1, abattoirToNumber(special.eventLeashRadius, 30))
        if playerPosition.z ~= anchorPosition.z or getDistanceBetween(playerPosition, anchorPosition) > leashRadius then
            AbattoirGem.reset(player, "distance")
            return
        end
    end

    addEvent(AbattoirGem.monitor, math.max(1, abattoirToNumber(special.monitorIntervalSeconds, 2)) * 1000, playerId, token)
end

function AbattoirGem.startMonitor(player)
    if not player then
        return
    end

    local runtime = AbattoirGem.getRuntime(player:getId())
    runtime.token = math.max(1, abattoirToNumber(runtime.token, 0)) + 1
    addEvent(AbattoirGem.monitor, math.max(1, abattoirToNumber(getSpecialConfig().monitorIntervalSeconds, 2)) * 1000, player:getId(), runtime.token)
end

function AbattoirGem.spawnCreature(player, tier, creatureName, spawnKind, state)
    if not player or not tier or type(creatureName) ~= "string" or creatureName == "" then
        return nil
    end

    local anchorPosition = player:getPosition()
    local spawnPosition = getSpawnPosition(anchorPosition)
    if not spawnPosition then
        return nil
    end

    local monster = Game.createMonster(creatureName, spawnPosition, false, true)
    if not monster then
        return nil
    end

    local playerId = player:getId()
    local runtime = AbattoirGem.getRuntime(playerId)
    runtime.anchor = getPositionData(anchorPosition)
    runtime.spawnedIds = runtime.spawnedIds or {}
    runtime.spawnedIds[#runtime.spawnedIds + 1] = monster:getId()
    AbattoirGem.spawnOwnerByMonsterId[monster:getId()] = {
        playerId = playerId,
        kind = spawnKind,
        tier = state and state.heatTier or 0,
    }

    if monster.selectTarget then
        monster:selectTarget(player)
    end
    if monster.setTarget then
        monster:setTarget(player)
    end

    if spawnKind == "boss" then
        local level = 1
        local item, socketIndex = AbattoirGem.findEquippedSocket(player)
        if item and socketIndex and type(_G.GemsSocket_getSocketGemLevel) == "function" then
            level = math.max(1, _G.GemsSocket_getSocketGemLevel(item, socketIndex))
        end

        local heatTier = math.max(1, abattoirToNumber(state and state.heatTier, 1))
        local healthMultiplier = 1 + (0.10 * level) + (0.08 * heatTier)
        local maxHealth = math.max(1, monster:getMaxHealth())
        local scaledHealth = math.floor(maxHealth * healthMultiplier)
        if scaledHealth > maxHealth then
            monster:setMaxHealth(scaledHealth)
            monster:addHealth("healing", scaledHealth - monster:getHealth())
        end
    end

    local special = getSpecialConfig()
    spawnPosition:sendMagicEffect(spawnKind == "boss" and (special.bossSpawnEffect or CONST_ME_TELEPORT) or (special.ambushSpawnEffect or CONST_ME_MORTAREA))
    return monster
end

function AbattoirGem.trySpawnEvent(player, item, socketIndex, state)
    local tier = AbattoirGem.tiers[math.max(0, abattoirToNumber(state.heatTier, 0))]
    if not tier then
        return false
    end

    local runtime = AbattoirGem.getRuntime(player:getId())
    if hasLiveSpawns(runtime) then
        return false
    end

    local level = type(_G.GemsSocket_getSocketGemLevel) == "function" and math.max(1, _G.GemsSocket_getSocketGemLevel(item, socketIndex)) or 1
    local bossChance = abattoirToNumber(tier.bossChance, 0) + getEquippedAbattoirBonus(player, "socket_abattoir_boss_bonus", level)
    local ambushChance = abattoirToNumber(tier.ambushChance, 0) + getEquippedAbattoirBonus(player, "socket_abattoir_ambush_bonus", level)

    if rollPercent(bossChance) then
        local bossName = chooseMonsterName(tier.bosses)
        if bossName then
            local boss = AbattoirGem.spawnCreature(player, tier, bossName, "boss", state)
            if boss then
                local anchor = player:getPosition()
                state.anchorX = anchor.x
                state.anchorY = anchor.y
                state.anchorZ = anchor.z
                state.activeBossId = boss:getId()
                AbattoirGem.writeState(item, socketIndex, state)
                AbattoirGem.refreshSocket(item, socketIndex)
                player:sendTextMessage(MESSAGE_INFO_DESCR, getMessages().boss or "The Abattoir opens. Survive the executioner.")
                return true
            end
        end
    end

    if rollPercent(ambushChance) then
        local count = math.max(1, abattoirToNumber(tier.ambushCount, 1))
        local spawned = 0
        for _ = 1, count do
            local monsterName = chooseMonsterName(tier.monsters)
            if monsterName and AbattoirGem.spawnCreature(player, tier, monsterName, "ambush", state) then
                spawned = spawned + 1
            end
        end
        if spawned > 0 then
            local anchor = player:getPosition()
            state.anchorX = anchor.x
            state.anchorY = anchor.y
            state.anchorZ = anchor.z
            state.activeBossId = 0
            AbattoirGem.writeState(item, socketIndex, state)
            AbattoirGem.refreshSocket(item, socketIndex)
            player:sendTextMessage(MESSAGE_INFO_DESCR, getMessages().ambush or "The Abattoir answers your slaughter.")
            return true
        end
    end

    return false
end

function AbattoirGem.awardBossReward(player, tierIndex, level)
    local special = getSpecialConfig()
    local itemId = tonumber(special.rewardItemId) or (GemsSocket and GemsSocket.ESSENCE and GemsSocket.ESSENCE.outputItemId) or 0
    if itemId <= 0 then
        return
    end

    local count = math.max(1, abattoirToNumber(special.rewardBaseCount, 2))
        + (math.max(1, abattoirToNumber(level, 1)) * math.max(0, abattoirToNumber(special.rewardPerGemLevel, 1)))
        + (math.max(0, abattoirToNumber(tierIndex, 0)) * math.max(0, abattoirToNumber(special.rewardPerHeatTier, 1)))
    player:addItem(itemId, count)
    player:getPosition():sendMagicEffect(special.rewardEffect or CONST_ME_HOLYAREA)
    player:sendTextMessage(MESSAGE_INFO_DESCR, getMessages().reward or "The Abattoir is satisfied.")
end

function AbattoirGem.handleSpawnKill(player, target)
    if not target or not target:isMonster() then
        return false
    end

    local monsterId = target:getId()
    local owner = AbattoirGem.spawnOwnerByMonsterId[monsterId]
    if not owner then
        return false
    end

    AbattoirGem.spawnOwnerByMonsterId[monsterId] = nil
    local runtime = AbattoirGem.runtime[owner.playerId]
    removeSpawnId(runtime, monsterId)

    if not player or not player:isPlayer() or player:getId() ~= owner.playerId then
        if owner.kind == "boss" then
            local ownerPlayer = Player(owner.playerId)
            if ownerPlayer then
                AbattoirGem.reset(ownerPlayer, "missing")
            end
        end
        return true
    end

    if owner.kind == "boss" then
        local item, socketIndex, state = AbattoirGem.findEquippedSocket(player)
        local level = item and socketIndex and type(_G.GemsSocket_getSocketGemLevel) == "function" and _G.GemsSocket_getSocketGemLevel(item, socketIndex) or 1
        local tierIndex = state and state.heatTier or owner.tier or 1
        AbattoirGem.awardBossReward(player, tierIndex, level)
        AbattoirGem.reset(player, nil)
    end
    return true
end

function AbattoirGem.onKill(player, target, lastHit)
    if not player or not player:isPlayer() or not target or not target:isMonster() then
        return false
    end

    AbattoirGem.handleSpawnKill(player, target)

    if lastHit == false then
        return false
    end
    if type(_G.GemsSocket_isNormalMonster) == "function" and not _G.GemsSocket_isNormalMonster(target) then
        return false
    end

    local item, socketIndex, state = AbattoirGem.findEquippedSocket(player)
    if not item or not socketIndex then
        return false
    end

    local level = type(_G.GemsSocket_getSocketGemLevel) == "function" and math.max(1, _G.GemsSocket_getSocketGemLevel(item, socketIndex)) or 1
    local gain = AbattoirGem.getChainGain(player, target, level)
    if gain <= 0 then
        return false
    end

    state = type(state) == "table" and state or {}
    state.chain = math.max(0, abattoirToNumber(state.chain, 0)) + gain
    state.lastKillTime = os.time()
    state.activeBossId = math.max(0, abattoirToNumber(state.activeBossId, 0))
    AbattoirGem.updateHeat(state)
    AbattoirGem.writeState(item, socketIndex, state)
    AbattoirGem.refreshSocket(item, socketIndex)
    AbattoirGem.startMonitor(player)

    if math.random(100) <= 8 then
        player:sendTextMessage(MESSAGE_STATUS_SMALL, string.format(getMessages().heatGain or "Abattoir heat rises: %d%%.", math.floor(state.heat or 0)))
    end

    AbattoirGem.trySpawnEvent(player, item, socketIndex, state)
    return true
end

function AbattoirGem.onLogout(player)
    if player and getSpecialConfig().resetOnLogout ~= false then
        AbattoirGem.reset(player, "logout")
    end
end

function AbattoirGem.onDeath(player)
    if player and getSpecialConfig().resetOnDeath ~= false then
        AbattoirGem.reset(player, "death")
    end
end

function AbattoirGem.onLogin(player)
    if player then
        AbattoirGem.startMonitor(player)
    end
end
