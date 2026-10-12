local corpseIds = {3058, 3059, 3060, 3061, 3064, 3065, 3066}
local removalLimit = 500
local RUNE_ID = 2310

function onCastSpell(creature, variant, isHotkey)
    local position = variant:getPosition()
    local tile = Tile(position)
    if tile then
        local items = tile:getItems()
        if items then
            for i, it in ipairs(items) do
                if it:getType():isMovable() and it:getUniqueId() > 65535 and it:getActionId() == 0 and not table.contains(corpseIds, it:getId()) then
                    it:remove()
                    playSound(creature, "desintegrate.ogg")
                end
                if i == removalLimit then
                    break
                end
            end
        end
    end

    local player = Player(creature)
    if not player then
        return false
    end

    if player:removeItem(RUNE_ID, 1) then
        position:sendMagicEffect(CONST_ME_POFF)
        return true
    end

    return false
end