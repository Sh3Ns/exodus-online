local maxAccountsPerIp = 4

AntiMcState = AntiMcState or {
    ipCounts = {},
    players = {},
    initialized = false,
}

local function normalizeIp(ip)
    return tonumber(ip) or 0
end

local function rebuildOnlineIpCounts()
    AntiMcState.ipCounts = {}
    AntiMcState.players = {}

    for _, onlinePlayer in ipairs(Game.getPlayers()) do
        local ip = normalizeIp(onlinePlayer:getIp())
        local guid = onlinePlayer:getGuid()

        AntiMcState.ipCounts[ip] = (AntiMcState.ipCounts[ip] or 0) + 1
        AntiMcState.players[guid] = ip
    end

    AntiMcState.initialized = true
end

local function ensureState()
    if not AntiMcState.initialized then
        rebuildOnlineIpCounts()
    end
end

function onLogin(player)
    ensureState()

    local ip = normalizeIp(player:getIp())
    local guid = player:getGuid()
    local currentCount = AntiMcState.ipCounts[ip] or 0

    if currentCount >= maxAccountsPerIp then
        return false
    end

    AntiMcState.ipCounts[ip] = currentCount + 1
    AntiMcState.players[guid] = ip
    return true
end
