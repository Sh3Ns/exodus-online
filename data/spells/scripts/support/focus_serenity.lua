local combat = Combat()
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, false)

local condition = Condition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT)
condition:setParameter(CONDITION_PARAM_TICKS, 7000)
combat:addCondition(condition)

local storageemblem = 405904
local storageDouble = 405905
local DURATION_MS = 7000

local sustainTimers = {}

local GUILD_EMBLEM_NONE = GUILDEMBLEM_NONE or 0
local GUILD_EMBLEM_CUSTOM = GUILDEMBLEM_CUSTOM or 6

local function resetEmblemAfterDuration(pid)
    local p = Player(pid)
    if not p then return end
    sustainTimers[pid] = nil

    if p:getStorageValue(storageemblem) == 1 then
        local guild = p:getGuild()
        if guild then
            p:setEmblem(GUILDEMBLEM_MEMBER)
        else
            p:setEmblem(GUILD_EMBLEM_NONE)
        end
        p:setStorageValue(storageemblem, -1)
        p:setStorageValue(storageDouble, -1)
    end
end

function onCastSpell(creature, variant)
    local player = Player(creature)
    if not player then return false end

    local pid = player:getId()
    if sustainTimers[pid] then
        stopEvent(sustainTimers[pid])
        sustainTimers[pid] = nil
    end

    playSound(player, "utamo.ogg")
    local result = combat:execute(player, variant)
    if not result then
        return false
    end

    player:setEmblem(GUILD_EMBLEM_CUSTOM)
    player:setStorageValue(storageemblem, 1)
    sustainTimers[pid] = addEvent(resetEmblemAfterDuration, DURATION_MS, pid)
    player:setStorageValue(storageDouble, 1)
    if MonkHarmony then
        MonkHarmony.activateSerenity(player)
    end
    return true
end
