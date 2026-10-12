local mortal = CreatureEvent("FerumbrasMortalShell")

function mortal.onDeath(creature, corpse, killer, mostDamageKiller)
    if creature:getName():lower() ~= "destabilized ferumbras" then
        return true
    end

    local pos = creature:getPosition()

    local boss = Game.createMonster("Ferumbras Mortal Shell", pos, true, true)
    if boss then
        pos:sendMagicEffect(CONST_ME_TELEPORT)
        boss:say("I ... will not fall so easily!", TALKTYPE_MONSTER_SAY)
    end

    return true
end

mortal:register()