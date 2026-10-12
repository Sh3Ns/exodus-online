local extendedEvent = CreatureEvent("GemsSocketExtended")

function extendedEvent.onExtendedOpcode(player, opcode, buffer)
    return GemsSocket_onExtendedOpcode(player, opcode, buffer)
end

extendedEvent:type("extendedopcode")
extendedEvent:register()

local loginEvent = CreatureEvent("GemsSocketLogin")

function loginEvent.onLogin(player)
    return GemsSocket_onLogin(player)
end

loginEvent:type("login")
loginEvent:register()

local logoutEvent = CreatureEvent("GemsSocketLogout")

function logoutEvent.onLogout(player)
    return GemsSocket_onLogout(player)
end

logoutEvent:type("logout")
logoutEvent:register()

local socketHealthEvent = CreatureEvent("GemsSocketOnHealthChange")

function socketHealthEvent.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
    return GemsSocket_onHealthChange(
        creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin
    )
end

socketHealthEvent:register()

local socketManaEvent = CreatureEvent("GemsSocketOnManaChange")

function socketManaEvent.onManaChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
    return GemsSocket_onManaChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
end

socketManaEvent:register()

local socketMonsterHealthEvent = CreatureEvent("GemsSocketOnMonsterHealthChange")

function socketMonsterHealthEvent.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
    primaryDamage, primaryType, secondaryDamage, secondaryType =
        GemsSocket_onMonsterHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)

    if type(_G.WheelDestiny_applyOutgoingCombat) == "function" then
        primaryDamage, primaryType, secondaryDamage, secondaryType = _G.WheelDestiny_applyOutgoingCombat(
            attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, creature, origin
        )
    end

    return primaryDamage, primaryType, secondaryDamage, secondaryType
end

socketMonsterHealthEvent:register()

local socketKillEvent = CreatureEvent("GemsSocketOnKill")

function socketKillEvent.onKill(player, target, lastHit)
    return GemsSocket_onKill(player, target, lastHit)
end

socketKillEvent:register()

local itemMoveEvent = EventCallback

function itemMoveEvent.onMoveItem(player, item, count, fromPosition, toPosition, fromCylinder, toCylinder)
    return GemsSocket_onMoveItem(player, item, count, fromPosition, toPosition, fromCylinder, toCylinder)
end

itemMoveEvent:register(9)

local itemMovedEvent = EventCallback

function itemMovedEvent.onItemMoved(player, item, count, fromPosition, toPosition, fromCylinder, toCylinder)
    return GemsSocket_onItemMoved(player, item, count, fromPosition, toPosition, fromCylinder, toCylinder)
end

itemMovedEvent:register(10)

local socketCombatTargetEvent = EventCallback

function socketCombatTargetEvent.onTargetCombat(creature, target)
    return GemsSocket_onTargetCombat(creature, target)
end

socketCombatTargetEvent:register(7)

local siphonBloomItemId = GemsSocket.SPECIALS
    and GemsSocket.SPECIALS.siphonBloom
    and tonumber(GemsSocket.SPECIALS.siphonBloom.bloomItemId)

if siphonBloomItemId and siphonBloomItemId > 0 then
    local siphonBloomStepIn = MoveEvent()

    function siphonBloomStepIn.onStepIn(player, item, position, fromPosition)
        return GemsSocket_onSiphonBloomStepIn(player, item, position, fromPosition)
    end

    siphonBloomStepIn:id(siphonBloomItemId)
    siphonBloomStepIn:type("stepin")
    siphonBloomStepIn:register()
end

for itemId, socketsToAdd in pairs(GemsSocket.SOCKET_ADDER_ITEMS) do
    GemsSocket_registerSocketAdderItem(itemId, socketsToAdd)
end

if type(_G.GemsSocket_registerAmplifierGem) == "function" then
    _G.GemsSocket_registerAmplifierGem()
end
