local function getCombinedAbsorb(target, storageIds)
    local total = 0
    if type(storageIds) ~= "table" then
        storageIds = { storageIds }
    end
    for _, storageId in ipairs(storageIds) do
        local v = target:getStorageValue(storageId) or 0
        if v < 0 then v = 0 end
        total = total + v
    end
    return total
end

local function applyAbsorb(dmg, sum)
    local sign = dmg < 0 and -1 or 1
    local absDmg = math.abs(dmg)
    local reducedAbs = math.floor(absDmg * (1 - sum/100))
    if absDmg > 0 and reducedAbs == 0 then
        reducedAbs = 1
    end
    return sign * reducedAbs
end

local creatureEvent = CreatureEvent("rarity_onHealthChangeAbsorb")
function creatureEvent.onHealthChange(target, source, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)

    if not target or not target:isPlayer() then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end
    --- If you want do a potion script or any other that applies absorbs, you need add a new storage on each line and use this storageIds, storage 1 and storage 2 are reserved
    local absorbTypes = {
        { type = COMBAT_FIREDAMAGE,    name = "Fire",     storages = {977544, 977562} },
        { type = COMBAT_PHYSICALDAMAGE, name = "Physical", storages = {977545, 977563} },
        { type = COMBAT_ENERGYDAMAGE,   name = "Energy",   storages = {977546, 977564} },
        { type = COMBAT_EARTHDAMAGE,    name = "Earth",    storages = {977547, 977565} },
        { type = COMBAT_DROWNDAMAGE,    name = "Drown",    storages = {977548, 977566} },
        { type = COMBAT_ICEDAMAGE,      name = "Ice",      storages = {977549, 977567} },
        { type = COMBAT_HOLYDAMAGE,     name = "Holy",     storages = {977550, 977568} },
        { type = COMBAT_DEATHDAMAGE,    name = "Death",    storages = {977551, 977569} },
        { type = COMBAT_WATERDAMAGE,    name = "Water",    storages = {977552, 977570} },
        { type = COMBAT_ARCANEDAMAGE,   name = "Arcane",   storages = {977553, 977571} },
        { type = COMBAT_LIFEDRAIN,      name = "Life Drain", storages = {977572, 977573} },
        { type = COMBAT_MANADRAIN,      name = "Mana Drain", storages = {977574, 977575} },
    }

    for _, absorb in ipairs(absorbTypes) do
        local sum = getCombinedAbsorb(target, absorb.storages)

        if sum > 0 and bit.band(primaryType, absorb.type) ~= 0 then
            if sum >= 100 then
                primaryDamage = 0
            else
                primaryDamage = applyAbsorb(primaryDamage, sum)
            end
        end

        if sum > 0 and bit.band(secondaryType or 0, absorb.type) ~= 0 then
            secondaryDamage = math.ceil(secondaryDamage * (1 - sum / 100))
        end

        if origin == ORIGIN_NONE and sum > 0 and bit.band(primaryType, absorb.type) ~= 0 then
            primaryDamage = math.ceil(primaryDamage * (1 - sum / 100))
        end
    end

    return primaryDamage, primaryType, secondaryDamage, secondaryType
end

creatureEvent:register()


local ec = EventCallback

function ec.onTargetCombat(creature, target)
    if creature and target then
        if creature:isPlayer() then
            target:registerEvent("rarity_onHealthChangeAbsorb")
        end
    end
    return RETURNVALUE_NOERROR
end

ec:register(7)