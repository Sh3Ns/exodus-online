local config = MakeBelieveQuestConfig
if not config or not config.rewards then
    error("[Phosphorus challenge] Reward configuration is missing.")
end

local rewards = config.rewards

local function grantMount(player, reward)
    if player:hasMount(reward.mountId) then
        return false
    end

    player:addMount(reward.mountId)
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
        string.format("You have obtained the %s mount!", reward.mountName))
    return true
end

function MakeBelieveGrantBossRewards(roomKey, players)
    if roomKey == "mimar" then
        for _, player in ipairs(players) do
            grantMount(player, rewards.mimarHaffar)
        end
        return
    end

    if roomKey ~= "phosphorus" then
        return
    end

    local reward = rewards.phosphorus
    for _, player in ipairs(players) do
        if not player:hasMount(reward.mountId) then
            local kills = math.max(0, player:getStorageValue(reward.killStorage))
            kills = math.min(reward.requiredKills, kills + 1)
            player:setStorageValue(reward.killStorage, kills)

            if kills >= reward.requiredKills then
                grantMount(player, reward)
            else
                player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
                    string.format("Phosphorus victories: %d/%d.", kills, reward.requiredKills))
            end
        end
    end
end

local cloudInABottle = Action()

function cloudInABottle.onUse(player, item)
    local reward = rewards.cloudInABottle
    if player:hasMount(reward.mountId) then
        player:sendCancelMessage("You already own the " .. reward.mountName .. " mount.")
        return true
    end

    if grantMount(player, reward) then
        item:remove(1)
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
    end
    return true
end

cloudInABottle:id(rewards.cloudInABottle.itemId)
cloudInABottle:register()
