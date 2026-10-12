--- [[ Warzone 2 feito por Yuri Lagrotta ]] ---
local BOSS = "gnomevil"
local bossPos = Position(33115, 31950, 11)
local enterPos = Position(33105, 31955, 11)
local exitPos = Position(33000, 31899, 9)

local bossCooldown = 99159
local spawnLock = 91149

local function bossExists()
    local spectators = Game.getSpectators(bossPos, false, false, 30, 30, 30, 30)
    for _, creature in ipairs(spectators) do
        if creature:isMonster() and creature:getName():lower() == BOSS then
            return true
        end
    end
    return false
end

local function spawnBoss()
    if Game.getStorageValue(spawnLock) < 1 then
        if not bossExists() then
            Game.createMonster(BOSS, bossPos)
        end
        Game.setStorageValue(spawnLock, 1)
        addEvent(function()
            Game.setStorageValue(spawnLock, 0)
        end, 30 * 60 * 1000)
    end
end

function onStepIn(creature, item, position, fromPosition)
    if not creature:isPlayer() then
        return false
    end

    if item.actionid == 5159 then
        if Game.getStorageValue(bossCooldown) < 1 then

            creature:teleportTo(enterPos)
            creature:sendTextMessage(MESSAGE_EVENT_ADVANCE,
                "You have half an hour to heroically defeat Gnomevil. Otherwise you'll be teleported out by the gnomish emergency device.")

            spawnBoss()

            Game.setStorageValue(bossCooldown, 1)
            addEvent(function()
                Game.setStorageValue(bossCooldown, 0)
            end, 2 * 60 * 1000)

        else
            creature:sendCancelMessage("Please wait before entering again.")
            creature:teleportTo(fromPosition)
        end

    elseif item.actionid == 5160 then
        creature:teleportTo(exitPos)
    end

    return true
end