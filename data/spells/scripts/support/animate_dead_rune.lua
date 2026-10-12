local ANIMATED_DEAD_RUNE = 2316

function onCastSpell(creature, variant, isHotkey)
    local player = Player(creature)
    if not player then
        return false
    end

    local position = variant:getPosition()
    local tile = Tile(position)

    if tile and creature:getSkull() ~= SKULL_BLACK then
        local corpse = tile:getTopDownItem()
        if corpse then
            local itemType = corpse:getType()
            if itemType:isCorpse() and itemType:isMovable() then
                local monster = Game.createMonster("Skeleton", position)
                if monster then
                    corpse:remove()
                    creature:addSummon(monster)

                    playSound(creature, "monster_summoned.ogg")
                    position:sendMagicEffect(CONST_ME_MAGIC_BLUE)
                    player:removeItem(ANIMATED_DEAD_RUNE, 1)
                    return true
                end
            end
        end
    end

    creature:getPosition():sendMagicEffect(CONST_ME_POFF)
    creature:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
    return false
end