-- Script maded by

--            _                   _             _     _      _    _          _        _                 _______
--           / /\                _\ \          /\ \ /_/\    /\ \ /\ \    _ / /\   _  /\ \              / ___  /\
--          / /  \              /\__ \        /  \ \\ \ \   \ \_\\ \ \  /_/ / /  /\_\\ \ \            / /\__\ \ \
--         / / /\ \            / /_ \_\      / /\ \ \\ \ \__/ / / \ \ \ \___\/  / / / \ \ \          / / /   \_\/
--        / / /\ \ \          / / /\/_/     / / /\ \_\\ \__ \/_/  / / /  \ \ \ / / /   \ \ \        / / /
--       / / /  \ \ \        / / /         / /_/_ \/_/ \/_/\__/\  \ \ \   \_\ \\ \ \____\ \ \       \ \ \
--      / / /___/ /\ \      / / /         / /____/\     _/\/__\ \  \ \ \  / / / \ \________\ \       \ \ \
--     / / /_____/ /\ \    / / / ____    / /\____\/    / _/_/\ \ \  \ \ \/ / /   \/________/\ \       \ \ \
--    / /_________/\ \ \  / /_/_/ ___/\ / / /______   / / /   \ \ \  \ \ \/ /              \ \ \  ____/ / /
--   / / /_       __\ \_\/_______/\__\// / /_______\ / / /    /_/ /   \ \  /                \ \_\/_____/ /
--   \_\___\     /____/_/\_______\/    \/__________/ \/_/     \_\/     \_\/                  \/_/\_____\/

print(">> Deck System Loaded")
--- Do not touch if you dont know what you are doing ---

local maxActivatedCards = 5
local activatedActionId = 37866
local activeCardCountStorage = 110016

local validDeckIds = {
    [27632] = true,
    [27633] = true,
    [27634] = true,
}

local cards = {
    [27482] = {value = DeckSystem.Cards.CommonErasmo, name = "Common Erasmo", effect = "Enhanced Exori with Earth"},
    [27483] = {value = DeckSystem.Cards.RareErasmo, name = "Rare Erasmo", effect = "Enhanced Exori with Ice"},
    [27484] = {value = DeckSystem.Cards.EpicErasmo, name = "Epic Erasmo", effect = "Enhanced Exori with Death"},
    [27485] = {value = DeckSystem.Cards.MythicErasmo, name = "Mythic Erasmo", effect = "Enhanced Exori with Energy"},
    [27486] = {value = DeckSystem.Cards.CommonDemetar, name = "Common Demetar", effect = "Enchanced Exevo Tera Hur with Fire"},
    [27487] = {value = DeckSystem.Cards.RareDemetar, name = "Rare Demetar", effect = "Enhanced Exevo Tera Hur with Holy"},
    [27488] = {value = DeckSystem.Cards.EpicDemetar, name = "Epic Demetar", effect = "Enhanced Exevo Tera Hur with Death"},
    [27489] = {value = DeckSystem.Cards.MythicDemetar, name = "Mythic Demetar", effect = "Enhanced Exevo Tera Hur with Energy"},
    [27490] = {value = DeckSystem.Cards.CommonKaishuter, name = "Common Kaishuter", effect = "Enhanced Exevo vis hur with Holy"},
    [27491] = {value = DeckSystem.Cards.RareKaishuter, name = "Rare Kaishuter", effect = "Enhanced Exevo vis hur with Ice"},
    [27492] = {value = DeckSystem.Cards.EpicKaishuter, name = "Epic Kaishuter", effect = "Enhanced Exevo vis hur with Drown"},
    [27493] = {value = DeckSystem.Cards.MythicKaishuter, name = "Mythic Kaishuter", effect = "Enhanced Exevo vis hur with Death"},
    [27494] = {value = DeckSystem.Cards.CommonEnragedChuo, name = "Common Enraged Chuo", effect = "Enhanced Exevo mas san with Fire"},
    [27495] = {value = DeckSystem.Cards.RareEnragedChuo, name = "Rare Enraged Chuo", effect = "Enhanced Exevo mas san with Ice"},
    [27496] = {value = DeckSystem.Cards.EpicEnragedChuo, name = "Epic Enraged Chuo", effect = "Enhanced Exevo mas san with Earth"},
    [27497] = {value = DeckSystem.Cards.MythicEnragedChuo, name = "Mythic Enraged Chuo", effect = "Enhanced Exevo mas san with Death"},
    [27498] = {value = DeckSystem.Cards.CommonZaika, name = "Common Zaika", effect = "Enhanced Avalanche Rune with Fire"},
    [27499] = {value = DeckSystem.Cards.RareZaika, name = "Rare Zaika", effect = "Enhanced Avalanche Rune with Earth"},
    [27500] = {value = DeckSystem.Cards.EpicZaika, name = "Epic Zaika", effect = "Enhanced Avalanche Rune with Energy"},
    [27501] = {value = DeckSystem.Cards.MythicZaika, name = "Mythic Zaika", effect = "Enhanced Avalanche Rune with Death"},
    [27502] = {value = DeckSystem.Cards.CommonRictus, name = "Common Rictus", effect = "Enhanced Exevo Gran Mas Frigo with Fire"},
    [27503] = {value = DeckSystem.Cards.RareRictus, name = "Rare Rictus", effect = "Enhanced Exevo Gran Mas Frigo with Holy"},
    [27504] = {value = DeckSystem.Cards.EpicRictus, name = "Epic Rictus", effect = "Enhanced Exevo Gran Mas Frigo with Death"},
    [27505] = {value = DeckSystem.Cards.MythicRictus, name = "Mythic Rictus", effect = "Enhanced Exevo Gran Mas Frigo with Energy"},
    [27506] = {value = DeckSystem.Cards.CommonGlobus, name = "Common Globus", effect = "Enhanced Exevo Gran Mas Vis with Holy"},
    [27507] = {value = DeckSystem.Cards.RareGlobus, name = "Rare Globus", effect = "Enhanced Exevo Gran Mas Vis with Earth"},
    [27508] = {value = DeckSystem.Cards.EpicGlobus, name = "Epic Globus", effect = "Enhanced Exevo Gran Mas Vis with Death"},
    [27509] = {value = DeckSystem.Cards.MythicGlobus, name = "Mythic Globus", effect = "Enhanced Exevo Gran Mas Vis with Ice"},
    [27510] = {value = DeckSystem.Cards.CommonHidaka, name = "Common Hidaka", effect = "Enhanced Exori Mas with Fire"},
    [27511] = {value = DeckSystem.Cards.RareHidaka, name = "Rare Hidaka", effect = "Enhanced Exori Mas with Earth"},
    [27512] = {value = DeckSystem.Cards.EpicHidaka, name = "Epic Hidaka", effect = "Enhanced Exori Mas with Ice"},
    [27513] = {value = DeckSystem.Cards.MythicHidaka, name = "Mythic Hidaka", effect = "Enhanced Exori Mas with Death"},
    [27514] = {value = DeckSystem.Cards.CommonBrelshaza, name = "Common Brelshaza", effect = "Enhanced, Minor Utito Tempo bonus"},
    [27515] = {value = DeckSystem.Cards.RareBrelshaza, name = "Rare Brelshaza", effect = "Enhanced, Major Utito Tempo bonus"},
    [27516] = {value = DeckSystem.Cards.EpicBrelshaza, name = "Epic Brelshaza", effect = "Enhanced, Intense Utito Tempo bonus"},
    [27517] = {value = DeckSystem.Cards.MythicBrelshaza, name = "Mythic Brelshaza", effect = "Enhanced, Powerful Utito Tempo bonus"},
    [27518] = {value = DeckSystem.Cards.CommonVairgrys, name = "Common Vairgrys", effect = "Enhanced Exevo Gran Flam hur with Ice"},
    [27519] = {value = DeckSystem.Cards.RareVairgrys, name = "Rare Vairgrys", effect = "Enhanced Exevo Gran Flam hur with Holy"},
    [27520] = {value = DeckSystem.Cards.EpicVairgrys, name = "Epic Vairgrys", effect = "Enhanced Exevo Gran Flam hur with Death"},
    [27521] = {value = DeckSystem.Cards.MythicVairgrys, name = "Mythic Vairgrys", effect = "Enhanced Exevo Gran Flam hur with Energy"},
    [27522] = {value = DeckSystem.Cards.CommonEnviska, name = "Common Enviska", effect = "Enhanced Exevo Gran Frigo Hur with Fire"},
    [27523] = {value = DeckSystem.Cards.RareEnviska, name = "Rare Enviska", effect = "Enhanced Exevo Gran Frigo Hur with Holy"},
    [27524] = {value = DeckSystem.Cards.EpicEnviska, name = "Epic Enviska", effect = "Enhanced Exevo Gran Frigo Hur with Death"},
    [27525] = {value = DeckSystem.Cards.MythicEnviska, name = "Mythic Enviska", effect = "Enhanced Exevo Gran Frigo Hur with Energy"},
    [27526] = {value = DeckSystem.Cards.CommonHarzal, name = "Common Harzal", effect = "Enhanced Exura Gran with minor bonus hp"},
    [27527] = {value = DeckSystem.Cards.RareHarzal, name = "Rare Harzal", effect = "Enhanced Exura Gran with major bonus hp"},
    [27528] = {value = DeckSystem.Cards.EpicHarzal, name = "Epic Harzal", effect = "Enhanced Exura Gran with intense bonus hp"},
    [27529] = {value = DeckSystem.Cards.MythicHarzal, name = "Mythic Harzal", effect = "Enhanced Exura Gran with powerful bonus hp"},
    [27530] = {value = DeckSystem.Cards.CommonAgaton, name = "Common Agaton", effect = "Enhanced Exori san with Fire"},
    [27531] = {value = DeckSystem.Cards.RareAgaton, name = "Rare Agaton", effect = "Enhanced Exori san with Earth"},
    [27532] = {value = DeckSystem.Cards.EpicAgaton, name = "Epic Agaton", effect = "Enhanced Exori san with Death"},
    [27533] = {value = DeckSystem.Cards.MythicAgaton, name = "Mythic Agaton", effect = "Enhanced Exori san with Energy"},
    [27534] = {value = DeckSystem.Cards.CommonLumerus, name = "Common Lumerus", effect = "Enhanced Exeta Res Minor Distance"},
    [27535] = {value = DeckSystem.Cards.RareLumerus, name = "Rare Lumerus", effect = "Enhanced Exeta Res Major Distance"},
    [27536] = {value = DeckSystem.Cards.EpicLumerus, name = "Epic Lumerus", effect = "Enhanced Exeta Res Instense Distance"},
    [27537] = {value = DeckSystem.Cards.MythicLumerus, name = "Mythic Lumerus", effect = "Enhanced Exeta Res Powerful Distance"},
    [27538] = {value = DeckSystem.Cards.CommonVelganos, name = "Common Velganos", effect = "Enhanced, Minor Utito Tempo san bonus"},
    [27539] = {value = DeckSystem.Cards.RareVelganos, name = "Rare Velganos", effect = "Enhanced, Major Utito Tempo san bonus"},
    [27540] = {value = DeckSystem.Cards.EpicVelganos, name = "Epic Velganos", effect = "Enhanced, Intense Utito Tempo san bonus"},
    [27541] = {value = DeckSystem.Cards.MythicVelganos, name = "Mythic Velganos", effect = "Enhanced, Powerful Utito Tempo san bonus"},
    [27547] = {value = DeckSystem.Legendary.LegendaryExoticAscalonLv6, name = "Exotic Ascalon Lv6", effect = "Sorcerer Legendary: 2% Chance to Summon a monster and increase your Magic Level by 3 for 25 seconds."},
    [27553] = {value = DeckSystem.Legendary.LegendaryChaosAscalonLv6, name = "Chaos Ascalon Lv6", effect = "Sorcerer Legendary: 3% Chance to Summon a monster and increase your Magic Level by 6 for 45 seconds."},
    [27559] = {value = DeckSystem.Legendary.LegendaryAbyssalAscalonLv6, name = "Abyssal Ascalon Lv6", effect = "Sorcerer Legendary: 4% Chance to Summon a monster and increase your Magic Level by 9 for 65 seconds."},
    [27565] = {value = DeckSystem.Legendary.LegendaryAncestralAscalonLv6, name = "Ancestral Ascalon Lv6", effect = "Sorcerer Legendary: 5% Chance to Summon a monster and increase your Magic Level by 15 for 90 seconds."},
    [27571] = {value = DeckSystem.Legendary.LegendaryExoticSaydonLv6, name = "Exotic Saydon Lv6", effect = "Druid Legendary: 2% Chance to Summon a monster and increase your Magic Level by 3 for 25 seconds."},
    [27577] = {value = DeckSystem.Legendary.LegendaryChaosSaydonLv6, name = "Chaos Saydon Lv6", effect = "Druid Legendary: 3% Chance to Summon a monster and increase your Magic Level by 6 for 45 seconds."},
    [27583] = {value = DeckSystem.Legendary.LegendaryAbyssalSaydonLv6, name = "Abyssal Saydon Lv6", effect = "Druid Legendary: 4% Chance to Summon a monster and increase your Magic Level by 9 for 65 seconds."},
    [27589] = {value = DeckSystem.Legendary.LegendaryAncestralSaydonLv6, name = "Ancestral Saydon Lv6", effect = "Druid Legendary: 5% Chance to Summon a monster and increase your Magic Level by 15 for 90 seconds."},
    [27595] = {value = DeckSystem.Legendary.LegendaryExoticVercruzeLv6, name = "Exotic Vercruze Lv6", effect = "Paladin Legendary: 2% Chance to Summon a monster and increase your Distance Skill by 3 for 25 seconds."},
    [27601] = {value = DeckSystem.Legendary.LegendaryChaosVercruzeLv6, name = "Chaos Vercruze Lv6", effect = "Paladin Legendary: 3% Chance to Summon a monster and increase your Distance Skill by 6 for 45 seconds."},
    [27607] = {value = DeckSystem.Legendary.LegendaryAbyssalVercruzeLv6, name = "Abyssal Vercruze Lv6", effect = "Paladin Legendary: 4% Chance to Summon a monster and increase your Distance Skill by 9 for 65 seconds."},
    [27640] = {value = DeckSystem.Legendary.LegendaryAncestralVercruzeLv6, name = "Ancestral Vercruze Lv6", effect = "Paladin Legendary: 5% Chance to Summon a monster and increase your Distance Skill by 15 for 90 seconds."},
    [27613] = {value = DeckSystem.Legendary.LegendaryExoticKaiserLv6, name = "Exotic Kaiser Lv6", effect = "Knight Legendary: 2% Chance to Summon a monster and increase your Skills by 3 for 25 seconds."},
    [27619] = {value = DeckSystem.Legendary.LegendaryChaosKaiserLv6, name = "Chaos Kaiser Lv6", effect = "Knight Legendary: 3% Chance to Summon a monster and increase your Skills by 6 for 45 seconds."},
    [27625] = {value = DeckSystem.Legendary.LegendaryAbyssalKaiserLv6, name = "Abyssal Kaiser Lv6", effect = "Knight Legendary: 4% Chance to Summon a monster and increase your Skills by 9 for 65 seconds."},
    [27631] = {value = DeckSystem.Legendary.LegendaryAncestralKaiserLv6, name = "Ancestral Kaiser Lv6", effect = "Knight Legendary: 5% Chance to Summon a monster and increase your Skills by 15 for 90 seconds."},
    [29958] = {value = DeckSystem.Cards.CommonPhokis, name = "Common Phokis", effect = "Enhanced, Forceful Uppercut with Fire Damage"},
    [29959] = {value = DeckSystem.Cards.RarePhokis, name = "Rare Phokis", effect = "Enhanced, Forceful Uppercut with Ice Damage"},
    [29960] = {value = DeckSystem.Cards.EpicPhokis, name = "Epic Phokis", effect = "Enhanced, Forceful Uppercut with Holy Damage"},
    [29961] = {value = DeckSystem.Cards.MythicPhokis, name = "Mythic Phokis", effect = "Enhanced, Forceful Uppercut with Death Damage"},
    [29962] = {value = DeckSystem.Cards.CommonNunkatu, name = "Common Nunkatu", effect = "Enhanced, Chained Penance with Water Damage"},
    [29963] = {value = DeckSystem.Cards.RareNunkatu, name = "Rare Nunkatu", effect = "Enhanced, Chained Penance with Earth Damage"},
    [29964] = {value = DeckSystem.Cards.EpicNunkatu, name = "Epic Nunkatu", effect = "Enhanced, Chained Penance with Holy Damage"},
    [29965] = {value = DeckSystem.Cards.MythicNunkatu, name = "Mythic Nunkatu", effect = "Enhanced, Chained Penance with Arcane Damage"},
    [29966] = {value = DeckSystem.Cards.CommonReaper, name = "Common Reaper", effect = "Enhanced, Sweeping Takedown with Physical Damage"},
    [29967] = {value = DeckSystem.Cards.RareReaper, name = "Rare Reaper", effect = "Enhanced, Sweeping Takedown with Fire Damage"},
    [29968] = {value = DeckSystem.Cards.EpicReaper, name = "Epic Reaper", effect = "Enhanced, Sweeping Takedown with Death Damage"},
    [29969] = {value = DeckSystem.Cards.MythicReaper, name = "Mythic Reaper", effect = "Enhanced, Sweeping Takedown with Water Damage"},
}

local function getActiveCardCount(player)
    local count = player:getStorageValue(activeCardCountStorage)
    if count >= 0 and count <= maxActivatedCards then
        return count
    end

    count = 0
    for _, card in pairs(cards) do
        if player:getStorageValue(card.value) == 1 then
            count = count + 1
        end
    end

    setActiveCardCount(player, count)
    return count
end

local function setActiveCardCount(player, count)
    player:setStorageValue(activeCardCountStorage, math.max(0, count))
end

local function isValidDeck(container)
    return container and validDeckIds[container:getId()] == true
end

local function getDeckContainer(player)
    local deckItem = player:getSlotItem(CONST_SLOT_DECK)
    if not deckItem or not deckItem:isContainer() then
        return nil
    end

    local container = Container(deckItem:getUniqueId())
    if not isValidDeck(container) then
        return nil
    end

    return container
end

local function syncAdditionalStorage(player, itemId)
    local additionalStorage = 110017 + (itemId - 27547)
    local value = player:getStorageValue(additionalStorage)
    if value == 0 or value == -1 then
        player:setStorageValue(additionalStorage, 1)
    end
end

local deckSystem = Action()

function deckSystem.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local card = cards[item:getId()]
    if not card then
        return false
    end

    local deckContainer = getDeckContainer(player)
    if not deckContainer then
        player:sendTextMessage(MESSAGE_INFO_DESCR, "This card cannot be used on this deck slot, use it on the correct deck slot or upgrade your deck slot in order to activate it.")
        return true
    end

    local currentValue = player:getStorageValue(card.value)
    if currentValue == 1 then
        player:setStorageValue(card.value, 0)
        item:setActionId(0)
        setActiveCardCount(player, getActiveCardCount(player) - 1)
        player:sendTextMessage(MESSAGE_INFO_DESCR, "You have Deactivated the card: " .. card.effect)
        playSound(player, "deck_card.ogg")
        return true
    end

    if getActiveCardCount(player) >= maxActivatedCards then
        player:sendTextMessage(MESSAGE_INFO_DESCR, "You have reached the maximum number of activated cards.")
        playSound(player, "fail.ogg")
        return true
    end

    player:setStorageValue(card.value, 1)
    item:setActionId(activatedActionId)
    setActiveCardCount(player, getActiveCardCount(player) + 1)
    syncAdditionalStorage(player, item:getId())
    player:sendTextMessage(MESSAGE_INFO_DESCR, "You have Activated the card: " .. card.effect)
    playSound(player, "deck_card.ogg")
    return true
end

for itemId in pairs(cards) do
    deckSystem:id(itemId)
end

deckSystem:register()

local deckStatus = TalkAction("!deck")

function deckStatus.onSay(player, words)
    local lines = {"Deck Card Status:"}
    for _, card in pairs(cards) do
        local status = player:getStorageValue(card.value) == 1 and "[*Activated*]" or "Deactivated"
        lines[#lines + 1] = card.name .. ": " .. status
    end
    player:showTextDialog(27634, table.concat(lines, "\n"))
    return false
end

deckStatus:register()
