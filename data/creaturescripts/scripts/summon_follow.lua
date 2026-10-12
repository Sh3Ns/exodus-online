local maxSummonDistance = 7

function onThink(creature, interval)
    local master = creature:getMaster()
    if not master then
        return true
    end

    local pos = creature:getPosition()
    local masterPos = master:getPosition()
    if masterPos.z ~= pos.z or getDistanceBetween(pos, masterPos) > maxSummonDistance then
        if creature:teleportTo(masterPos) then
            pos:sendMagicEffect(CONST_ME_POFF)
        end
    end
    return true
end
