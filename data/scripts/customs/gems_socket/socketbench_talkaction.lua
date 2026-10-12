-- Used to check caches and optimize the Gem Socket System
-- Both Socketbench and Socketload talkaction can be removed from the game.
local socketCacheTalk = TalkAction("!socketcache", "/socketcache")

function socketCacheTalk.onSay(player, words, param)
    if not player or not player:isPlayer() then
        return false
    end

    if type(_G.GemsSocket_debugCompareBonusCache) ~= "function" then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Socket cache debug function is not loaded.")
        return false
    end

    local key = tostring(param or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if key == "" then
        key = nil
    end

    local result = _G.GemsSocket_debugCompareBonusCache(player, key)
    if not result or result.ok == false and result.message then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, result and result.message or "Socket cache compare failed.")
        return false
    end

    if result.ok then
        if result.requestedKey then
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format(
                "Socket cache OK. %s cached=%s legacy=%s.",
                tostring(result.requestedKey),
                tostring(result.cached),
                tostring(result.legacy)
            ))
        else
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format("Socket cache OK. Checked %d bonus key%s.", result.checked or 0, (result.checked or 0) == 1 and "" or "s"))
        end
        return false
    end

    local mismatches = result.mismatches or {}
    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format("Socket cache mismatch: %d/%d key%s differ.", #mismatches, result.checked or 0, (result.checked or 0) == 1 and "" or "s"))
    for index = 1, math.min(10, #mismatches) do
        local mismatch = mismatches[index]
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format("%s cached=%s legacy=%s", tostring(mismatch.key), tostring(mismatch.cached), tostring(mismatch.legacy)))
    end
    if #mismatches > 10 then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format("Only first 10 mismatches shown. Use !socketcache bonus_key to inspect one key."))
    end
    return false
end

socketCacheTalk:separator(" ")
socketCacheTalk:register()

local socketBenchTalk = TalkAction("!socketbench", "/socketbench")

function socketBenchTalk.onSay(player, words, param)
    if not player or not player:isPlayer() or not player:getGroup():getAccess() then
        return false
    end
    if type(_G.GemsSocket_getPerformanceMetrics) ~= "function" then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Socket performance metrics are not loaded.")
        return false
    end

    local reset = tostring(param or ""):lower():match("^%s*reset%s*$") ~= nil
    local metrics = _G.GemsSocket_getPerformanceMetrics(reset)
    local elapsed = math.max(1, tonumber(metrics.elapsed) or 1)
    local function rate(name)
        return (tonumber(metrics[name]) or 0) / elapsed
    end

    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format(
        "Socket bench %ds: cache %.1f hits/s, %.2f misses/s, %.2f rebuilds/s, legacy %.2f scans/s.",
        elapsed, rate("cache_hits"), rate("cache_misses"), rate("rebuilds"), rate("legacy_total_scans")
    ))
    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format(
        "Runtime: %.1f player hits/s, %.1f monster hits/s, %.1f fast exits/s, %.2f kills/s, %.1f advanced pulses/s, %.1f utility players/s.",
        rate("player_health_events"), rate("monster_health_events"), rate("combat_fast_exits"),
        rate("kill_events"), rate("advanced_pulses"), rate("utility_player_ticks")
    ))
    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format(
        "Items: %.2f recomputes/s, %.2f display refreshes/s (%.2f merged/s), %.2f player refreshes/s, %.2f moves skipped/s, %.1f indexed sockets/s.",
        rate("item_recomputes"), rate("display_refreshes"), rate("display_refreshes_coalesced"),
        rate("player_bonus_refreshes"), rate("item_moves_skipped"), rate("indexed_socket_visits")
    ))
    if type(_G.GemsSocketVisibilitySyncQueue) == "table" then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format(
            "Visibility sync work pending: %d.", _G.GemsSocketVisibilitySyncQueue.getPendingCount()
        ))
    end
    if reset then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Socket performance counters reset.")
    end
    return false
end

socketBenchTalk:separator(" ")
socketBenchTalk:register()
