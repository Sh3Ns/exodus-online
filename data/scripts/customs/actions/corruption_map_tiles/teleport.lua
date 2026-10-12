local corruptionMap = MoveEvent()

function corruptionMap.onStepIn(creature, item, position, fromPosition)
    local player = creature:getPlayer()
    if not player then
        return true
    end

    if item.actionid == 22719 then
        local destination = Position(32184, 31573, 11)
        player:teleportTo(destination)
    elseif item.actionid == 22720 then
        local destination = Position(32185, 31573, 11)
        player:teleportTo(destination)
    elseif item.actionid == 22721 then
        local destination = Position(32186, 31573, 11)
        player:teleportTo(destination)
    elseif item.actionid == 22722 then
        local destination = Position(32237, 31534, 8)
        player:teleportTo(destination)
    elseif item.actionid == 22723 then
        local destination = Position(32238, 31534, 8)
        player:teleportTo(destination)
    elseif item.actionid == 22724 then
        local destination = Position(32239, 31534, 8)
        player:teleportTo(destination)
    end

    return true
end

corruptionMap:type("StepIn")
corruptionMap:aid(22719, 22720, 22721, 22722, 22723, 22724)
corruptionMap:register()
