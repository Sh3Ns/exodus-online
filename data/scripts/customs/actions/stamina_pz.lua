local pzStamina = GlobalEvent("PZStamina")

local STAMINA_MAX = 2520
local ORANGE_LIMIT = 2400

local ORANGE_MINUTES_PER_POINT = 3
local GREEN_MINUTES_PER_POINT  = 10

local TICK_INTERVAL = 60

-- Runtime tracking
local active = {}
local accumulators = {}

local function regenStamina(playerId)
    local player = Player(playerId)
    if not player then
        active[playerId] = nil
        accumulators[playerId] = nil
        return
    end

    local tile = Tile(player:getPosition())
    if not tile or not tile:hasFlag(TILESTATE_PROTECTIONZONE) then
        active[playerId] = nil
        accumulators[playerId] = nil
        return
    end

    local stamina = player:getStamina()
    if stamina >= STAMINA_MAX then
        active[playerId] = nil
        accumulators[playerId] = nil
        return
    end

    accumulators[playerId] = (accumulators[playerId] or 0) + 1

    local neededMinutes
    if stamina <= ORANGE_LIMIT then
        neededMinutes = ORANGE_MINUTES_PER_POINT
    else
        neededMinutes = GREEN_MINUTES_PER_POINT
    end

    if accumulators[playerId] >= neededMinutes then
        accumulators[playerId] = 0
        player:setStamina(math.min(STAMINA_MAX, stamina + 1))
    end

    active[playerId] = addEvent(regenStamina, TICK_INTERVAL * 1000, playerId)
end

function pzStamina.onStartup()
    for _, player in ipairs(Game.getPlayers()) do
        local tile = Tile(player:getPosition())
        if tile and tile:hasFlag(TILESTATE_PROTECTIONZONE) then
            local pid = player:getId()
            if not active[pid] then
                accumulators[pid] = 0
                active[pid] = addEvent(regenStamina, TICK_INTERVAL * 1000, pid)
            end
        end
    end
    return true
end

pzStamina:register()

local loginEvent = CreatureEvent("PZStaminaLogin")
function loginEvent.onLogin(player)
    local tile = Tile(player:getPosition())
    if tile and tile:hasFlag(TILESTATE_PROTECTIONZONE) then
        local pid = player:getId()
        if not active[pid] then
            accumulators[pid] = 0
            player:sendTextMessage(MESSAGE_INFO_DESCR, "Regenerating stamina in depot.")
            active[pid] = addEvent(regenStamina, TICK_INTERVAL * 1000, pid)
        end
    end
    return true
end
loginEvent:register()

local moveEventIn = MoveEvent()

function moveEventIn.onStepIn(player, item, position, fromPosition)
    local pid = player:getId()
    if not active[pid] then
        accumulators[pid] = 0
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Regenerating stamina in depot.")
        active[pid] = addEvent(regenStamina, TICK_INTERVAL * 1000, pid)
    end
    return true
end

moveEventIn:type("stepin")
moveEventIn:register()

local moveEventOut = MoveEvent()

function moveEventOut.onStepOut(player, item, position, fromPosition)
    local pid = player:getId()
    if active[pid] then
        stopEvent(active[pid])
        active[pid] = nil
        accumulators[pid] = nil
    end
    return true
end

moveEventOut:type("stepout")
moveEventOut:register()