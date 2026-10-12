setDefaultTab("Tools")

local targetID = nil

-- escape when attacking will reset hold target
onKeyPress(function(keys)
    if keys == "Escape" and targetID then
        targetID = nil
    end
end)

macro(100, "Hold Target", function()
    local currentTarget = target()

    -- if attacking then save it as target, but check pos z in case of marking by mistake on other floor
    if currentTarget then
        local currentTargetPos = currentTarget:getPosition()
        if currentTargetPos and currentTargetPos.z == posz() and not currentTarget:isNpc() then
            targetID = currentTarget:getId()
        end
    else
        -- there is no saved data, do nothing
        if not targetID then return end

        -- look for target
        for _, spec in ipairs(getSpectators()) do
            local specPos = spec:getPosition()
            local sameFloor = specPos and specPos.z == posz()
            local oldTarget = spec:getId() == targetID
            
            if sameFloor and oldTarget then
                attack(spec)
                break
            end
        end
    end
end)
