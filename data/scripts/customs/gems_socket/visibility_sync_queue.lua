GemsSocketVisibilitySyncQueue = GemsSocketVisibilitySyncQueue or {}

local queue = GemsSocketVisibilitySyncQueue
local jobs = {}
local running = false
local pendingPairs = {}

local function getSettings()
    local config = GemsSocket and GemsSocket.PERFORMANCE or {}
    return math.max(10, tonumber(config.visibilitySyncBatchSize) or 75),
        math.max(1, tonumber(config.visibilitySyncIntervalMs) or 10),
        math.max(1, tonumber(config.visibilitySyncNearbyRangeX) or 18),
        math.max(1, tonumber(config.visibilitySyncNearbyRangeY) or 14)
end

local function getPairKey(playerId, monsterId)
    return string.format("%d:%d", tonumber(playerId) or 0, tonumber(monsterId) or 0)
end

local function clearPendingJob(job)
    if type(job) ~= "table" then
        return
    end
    for index = tonumber(job.index) or 1, #(job.playerIds or {}) do
        pendingPairs[getPairKey(job.playerIds[index], job.monsterId)] = nil
    end
end

local function addPlayerId(playerIds, seen, player, monsterId)
    if not player or not player.isPlayer or not player:isPlayer() then
        return
    end
    local playerId = player:getId()
    if seen[playerId] or pendingPairs[getPairKey(playerId, monsterId)] then
        return
    end
    seen[playerId] = true
    pendingPairs[getPairKey(playerId, monsterId)] = true
    playerIds[#playerIds + 1] = playerId
end

local function runQueue()
    local batchSize, intervalMs = getSettings()
    local processed = 0

    while processed < batchSize and #jobs > 0 do
        local job = jobs[1]
        local monster = Monster(job.monsterId)
        if not monster or monster:isRemoved() then
            clearPendingJob(job)
            table.remove(jobs, 1)
        else
            local playerId = job.playerIds[job.index]
            if not playerId then
                table.remove(jobs, 1)
            else
                job.index = job.index + 1
                pendingPairs[getPairKey(playerId, job.monsterId)] = nil
                local player = Player(playerId)
                if player then
                    player:syncCreatureVisibility(monster, false, true)
                end
                processed = processed + 1
            end
        end
    end

    if #jobs > 0 then
        addEvent(runQueue, intervalMs)
    else
        running = false
    end
end

function queue.enqueueMonster(monster, forceGlobal)
    if not monster or not monster:isMonster() then
        return false
    end

    local monsterId = monster:getId()
    local playerIds = {}
    local seen = {}
    local _, _, rangeX, rangeY = getSettings()
    local position = monster:getPosition()

    if not forceGlobal and position then
        for _, spectator in ipairs(Game.getSpectators(position, false, true, rangeX, rangeX, rangeY, rangeY) or {}) do
            addPlayerId(playerIds, seen, spectator, monsterId)
        end
    end

    if forceGlobal then
        for _, player in ipairs(Game.getPlayers()) do
            addPlayerId(playerIds, seen, player, monsterId)
        end
    end

    if #playerIds == 0 then
        return true
    end

    jobs[#jobs + 1] = {
        monsterId = monsterId,
        playerIds = playerIds,
        index = 1,
    }
    if not running then
        running = true
        addEvent(runQueue, 1)
    end
    return true
end

function queue.getPendingCount()
    local count = 0
    for _, job in ipairs(jobs) do
        count = count + math.max(0, #job.playerIds - job.index + 1)
    end
    return count
end
