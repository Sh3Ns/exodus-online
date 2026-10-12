local socketLook = EventCallback

function socketLook.onLook(self, thing, position, distance, description)
    if not thing:isItem() then
        return description
    end

    local ensureGemItemMetadata = _G.GemsSocket_ensureGemItemMetadata
    local getSocketCount = _G.GemsSocket_getSocketCount
    local getSocketGemKey = _G.GemsSocket_getSocketGemKey
    local hasSockets = _G.GemsSocket_hasSockets

    if type(getSocketCount) ~= "function" or type(getSocketGemKey) ~= "function" or type(hasSockets) ~= "function" then
        return description
    end

    if type(ensureGemItemMetadata) == "function" and ensureGemItemMetadata(thing) then
        local gemName = thing:getCustomAttribute("gem_name") or ItemType(thing:getId()):getName() or "Unknown Gem"
        local gemTooltip = thing:getCustomAttribute("gem_tooltip") or ""
        if gemTooltip ~= "" then
            return string.format("%s\n%s", description, gemTooltip)
        end
        return string.format("%s\n%s", description, gemName)
    end

    if not hasSockets(thing) then
        return description
    end

    local socketCount = getSocketCount(thing)

    description = string.format("%s\nSockets: %d", description, socketCount)
    for index = 1, socketCount do
        local gemKey = getSocketGemKey(thing, index)
        if gemKey then
            local gemName = thing:getCustomAttribute(string.format("socket_%d_name", index)) or "Unknown Gem"
            local gemTooltip = thing:getCustomAttribute(string.format("socket_%d_tooltip", index)) or ""
            description = gemTooltip ~= ""
                and string.format("%s\n[%d] %s\n%s", description, index, gemName, gemTooltip)
                or string.format("%s\n[%d] %s", description, index, gemName)
        else
            description = string.format("%s\n[%d] Empty", description, index)
        end
    end

    return description
end

socketLook:register()
