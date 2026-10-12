-- Created This script in order to Optimize  the Gem Socket System - Results: 500 Players Online = Passed.
-- I leave the scripts if someone want to adjust or add/remove some gems.
-- Single-player synthetic socket load benchmark for TFS/Revscriptsys.
-- Put in: data/scripts/customs/gems_socket/socketload_talkaction.lua
--
-- Commands:
--   !socketload lookup 20000
--   !socketload rebuild 500
--
-- "lookup" measures cached hot-path bonus reads.
-- "rebuild" invalidates and rebuilds the player's socket cache repeatedly.
--
-- Keep caps low on live. This runs on the game thread.
-- Both Socketbench and Socketload talkaction can be removed from the game.

local socketLoadTalk = TalkAction("!socketload", "/socketload")

local hotKeys = {
    "socket_dodge_chance",
    "socket_parry_chance",
    "socket_parry_percent",
    "socket_thorns_chance",
    "socket_thorns_damage",
    "socket_guard_chance",
    "socket_guard_percent",
    "socket_second_wind_chance",
    "socket_second_wind_percent",
    "socket_mana_surge_chance",
    "socket_mana_surge_percent",
    "socket_cleanse_chance",
    "socket_execute_chance",
    "socket_execute_threshold",
    "socket_execute_percent",
    "socket_chronicle_damage_percent",
    "socket_living_damage_percent",
    "socket_cripple_chance",
    "socket_cripple_duration",
    "socket_cripple_speed",
    "socket_spellfury_chance",
    "socket_spellfury_percent",
    "socket_abyssal_depths_chance",
    "socket_abyssal_depths_percent",
    "socket_venomstone_chance",
    "socket_venomstone_percent",
    "socket_requiem_chance",
    "socket_requiem_cooldown",
    "socket_martyr_chance",
    "socket_martyr_percent",
    "socket_phantom_chance",
    "socket_phantom_duration",
    "socket_phantom_cooldown",
    "socket_roll_chance",
    "socket_roll_cooldown",
    "socket_infection_chance",
    "socket_infection_range",
    "socket_infection_targets",
}

local function trim(value)
    return tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function splitWords(value)
    local out = {}
    for word in tostring(value or ""):gmatch("%S+") do
        out[#out + 1] = word
    end
    return out
end

local function send(player, text)
    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, text)
    print(text)
end

local function runLookup(player, loops)
    local getBonus = _G.GemsSocket_getEquippedSocketBonusTotal
    if type(getBonus) ~= "function" then
        send(player, "SocketLoad: GemsSocket_getEquippedSocketBonusTotal is not loaded.")
        return
    end

    -- Warm cache first.
    getBonus(player, hotKeys[1])

    local checksum = 0
    local started = os.clock()
    for i = 1, loops do
        for k = 1, #hotKeys do
            checksum = checksum + (tonumber(getBonus(player, hotKeys[k])) or 0)
        end
    end

    local elapsed = math.max(0.000001, os.clock() - started)
    local lookups = loops * #hotKeys
    local avgUs = elapsed * 1000000 / math.max(1, lookups)

    -- Estimates only cached bonus lookup CPU, not actual effects/spectator scans/damage.
    local est500_1 = 500 * 1 * #hotKeys * avgUs / 1000
    local est500_5 = 500 * 5 * #hotKeys * avgUs / 1000
    local est500_10 = 500 * 10 * #hotKeys * avgUs / 1000

    send(player, string.format(
        "SocketLoad lookup: loops=%d keys=%d lookups=%d elapsed=%.4fs avg=%.3fus/read CPU500≈%.1f/%.1f/%.1f ms per sec at 1/5/10 events-sec checksum=%d",
        loops, #hotKeys, lookups, elapsed, avgUs, est500_1, est500_5, est500_10, checksum
    ))
end

local function runRebuild(player, loops)
    local invalidate = _G.GemsSocket_invalidatePlayerBonusCache
    local getBonus = _G.GemsSocket_getEquippedSocketBonusTotal
    if type(invalidate) ~= "function" or type(getBonus) ~= "function" then
        send(player, "SocketLoad: cache invalidate/getBonus functions are not loaded.")
        return
    end

    local checksum = 0
    local started = os.clock()
    for i = 1, loops do
        invalidate(player)
        checksum = checksum + (tonumber(getBonus(player, hotKeys[1])) or 0)
    end

    local elapsed = math.max(0.000001, os.clock() - started)
    local avgMs = elapsed * 1000 / math.max(1, loops)

    send(player, string.format(
        "SocketLoad rebuild: loops=%d elapsed=%.4fs avg=%.3fms/rebuild est500-one-rebuild-pass=%.1fms checksum=%d",
        loops, elapsed, avgMs, avgMs * 500, checksum
    ))
end

function socketLoadTalk.onSay(player, words, param)
    if not player or not player:isPlayer() or not player:getGroup():getAccess() then
        return false
    end

    local args = splitWords(param)
    local mode = trim(args[1] or "lookup"):lower()
    local requested = math.max(1, tonumber(args[2]) or (mode == "rebuild" and 200 or 10000))

    if mode == "lookup" then
        local loops = math.min(requested, 100000)
        runLookup(player, loops)
        if requested > loops then
            send(player, "SocketLoad: lookup loops capped to 100000.")
        end
        return false
    end

    if mode == "rebuild" then
        local loops = math.min(requested, 2000)
        runRebuild(player, loops)
        if requested > loops then
            send(player, "SocketLoad: rebuild loops capped to 2000.")
        end
        return false
    end

    send(player, "Usage: !socketload lookup 20000 OR !socketload rebuild 500")
    return false
end

socketLoadTalk:separator(" ")
socketLoadTalk:register()
