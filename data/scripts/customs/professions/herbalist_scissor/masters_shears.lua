local herbalistSystem = Action()
local COOLDOWN_SECONDS = 4

local config = {
    [26741] = {text = {"The plant is regenerating."}}, 
    [26717] = {break_chance = 75, loot_chance = 80, lower_tier = 26741, requiredSkill = 0, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 26731, count = 1}, 
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 26729, count = 2}, 
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 26729, count = 4},
        },
    },
    [26742] = {text = {"The plant is regenerating."}}, 
    [26718] = {break_chance = 75, loot_chance = 80, lower_tier = 26742, requiredSkill = 5, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 26730, count = 1}, 
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 26732, count = 2}, 
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 26732, count = 4},
        },
    },
    [26743] = {text = {"The plant is regenerating."}}, 
    [26719] = {break_chance = 75, loot_chance = 80, lower_tier = 26743, requiredSkill = 15, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 26725, count = 1}, 
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 26726, count = 2}, 
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 26726, count = 4},
        },
    },
    [26744] = {text = {"The plant is regenerating."}}, 
    [26720] = {break_chance = 75, loot_chance = 80, lower_tier = 26744, requiredSkill = 20, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 26727, count = 1}, 
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 26727, count = 2}, 
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 26727, count = 4},
        },
    },
    [26745] = {text = {"The mushroom is regenerating."}}, 
    [26721] = {break_chance = 75, loot_chance = 80, lower_tier = 26745, requiredSkill = 30, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 26723, count = 1}, 
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 26724, count = 2}, 
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 26724, count = 4},
        },
    },
    [26746] = {text = {"The plant is regenerating."}}, 
    [26722] = {break_chance = 75, loot_chance = 80, lower_tier = 26746, requiredSkill = 40, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 26728, count = 1}, 
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 26728, count = 2}, 
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 26728, count = 4},
        },
    },
    [30146] = {text = {"Twilight flower is regenerating."}},
    [30145] = {break_chance = 65, loot_chance = 80, lower_tier = 30146, requiredSkill = 50,
        normal_loot_table = { -- 80%
            [1] = {item_id = 30226, count = 2},
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 30226, count = 3},
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 30226, count = 6},
        },
    },
    [30148] = {text = {"Twilight flower is regenerating."}},
    [30147] = {break_chance = 65, loot_chance = 80, lower_tier = 30148, requiredSkill = 50,
        normal_loot_table = { -- 80%
            [1] = {item_id = 30226, count = 2},
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 30226, count = 3},
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 30226, count = 6},
        },
    },
    [30150] = {text = {"Moonsang cocoon is regenerating."}},
    [30149] = {break_chance = 65, loot_chance = 80, lower_tier = 30150, requiredSkill = 50,
        normal_loot_table = { -- 80%
            [1] = {item_id = 30227, count = 2},
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 30227, count = 3},
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 30227, count = 6},
        },
    },
    [30157] = {text = {"Umbrapetal mushroom is regenerating."}},
    [30156] = {break_chance = 65, loot_chance = 80, lower_tier = 30157, requiredSkill = 50,
        normal_loot_table = { -- 80%
            [1] = {item_id = 30231, count = 2},
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 30231, count = 3},
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 30231, count = 6},
        },
    },
    [30159] = {text = {"Sanguibloom flower is regenerating."}},
    [30158] = {break_chance = 65, loot_chance = 80, lower_tier = 30159, requiredSkill = 50,
        normal_loot_table = { -- 80%
            [1] = {item_id = 30232, count = 2},
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 30232, count = 3},
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 30232, count = 6},
        },
    },
    [30161] = {text = {"Aetherblossom flower is regenerating."}},
    [30160] = {break_chance = 65, loot_chance = 80, lower_tier = 30161, requiredSkill = 50,
        normal_loot_table = { -- 80%
            [1] = {item_id = 30233, count = 2},
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 30233, count = 3},
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 30233, count = 6},
        },
    },
    [30163] = {text = {"Noctilume flower is regenerating."}},
    [30162] = {break_chance = 65, loot_chance = 80, lower_tier = 30163, requiredSkill = 50,
        normal_loot_table = { -- 80%
            [1] = {item_id = 30234, count = 2},
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 30234, count = 3},
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 30234, count = 6},
        },
    },
    [30165] = {text = {"Thornveil herb is regenerating."}},
    [30164] = {break_chance = 65, loot_chance = 80, lower_tier = 30165, requiredSkill = 50,
        normal_loot_table = { -- 80%
            [1] = {item_id = 30235, count = 2},
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 30235, count = 3},
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 30235, count = 6},
        },
    },
    [30167] = {text = {"Heliara herb is regenerating."}},
    [30166] = {break_chance = 65, loot_chance = 80, lower_tier = 30167, requiredSkill = 50,
        normal_loot_table = { -- 80%
            [1] = {item_id = 30236, count = 2},
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 30236, count = 3},
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 30236, count = 6},
        },
    },
    [30169] = {text = {"Zaphyra herb is regenerating."}},
    [30168] = {break_chance = 65, loot_chance = 80, lower_tier = 30169, requiredSkill = 50,
        normal_loot_table = { -- 80%
            [1] = {item_id = 30237, count = 2},
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 30237, count = 3},
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 30237, count = 6},
        },
    },
    [30171] = {text = {"Rotcap fungus is regenerating."}},
    [30170] = {break_chance = 65, loot_chance = 80, lower_tier = 30171, requiredSkill = 50,
        normal_loot_table = { -- 80%
            [1] = {item_id = 30238, count = 2},
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 30238, count = 3},
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 30238, count = 6},
        },
    },
    [30188] = {text = {"Colybis fungus is regenerating."}},
    [30182] = {break_chance = 65, loot_chance = 80, lower_tier = 30188, requiredSkill = 50,
        normal_loot_table = { -- 80%
            [1] = {item_id = 30244, count = 2},
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 30244, count = 3},
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 30244, count = 6},
        },
    },
    [30189] = {text = {"Agrocybe fungus is regenerating."}},
    [30183] = {break_chance = 65, loot_chance = 80, lower_tier = 30189, requiredSkill = 50,
        normal_loot_table = { -- 80%
            [1] = {item_id = 30245, count = 2},
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 30245, count = 3},
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 30245, count = 6},
        },
    },
    [30190] = {text = {"Psyliota mushroom is regenerating."}},
    [30184] = {break_chance = 65, loot_chance = 80, lower_tier = 30190, requiredSkill = 50,
        normal_loot_table = { -- 80%
            [1] = {item_id = 30246, count = 2},
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 30246, count = 3},
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 30246, count = 6},
        },
    },
    [30191] = {text = {"Laccaria fungus is regenerating."}},
    [30185] = {break_chance = 65, loot_chance = 80, lower_tier = 30191, requiredSkill = 50,
        normal_loot_table = { -- 80%
            [1] = {item_id = 30247, count = 2},
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 30247, count = 3},
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 30247, count = 6},
        },
    },
    [30192] = {text = {"Virelia plant is regenerating."}},
    [30186] = {break_chance = 65, loot_chance = 80, lower_tier = 30192, requiredSkill = 50,
        normal_loot_table = { -- 80%
            [1] = {item_id = 30248, count = 2},
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 30248, count = 3},
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 30248, count = 6},
        },
    },
    [30193] = {text = {"Auralis plant is regenerating."}},
    [30187] = {break_chance = 65, loot_chance = 80, lower_tier = 30193, requiredSkill = 50,
        normal_loot_table = { -- 80%
            [1] = {item_id = 30249, count = 2},
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 30249, count = 3},
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 30249, count = 6},
        },
    },
}

_G.ProfessionGatheringResources = _G.ProfessionGatheringResources or {}
for resourceId, resourceData in pairs(config) do
    if resourceData.lower_tier then
        _G.ProfessionGatheringResources[resourceId] = {
            profession = "herbalist",
            skill = SKILL_HERBALIST,
            data = resourceData,
        }
    end
end

local skillsStages = {
    {
        minlevel = 10,
        maxlevel = 20,
        multiplier = 30
    }, {
        minlevel = 21,
        maxlevel = 40,
        multiplier = 20
    }, {
        minlevel = 41,
        maxlevel = 60,
        multiplier = 15
    }, {
        minlevel = 61,
        maxlevel = 90,
        multiplier = 10
    }, {
        minlevel = 91,
        maxlevel = 120,
        multiplier = 8
    },{
        minlevel = 121,
        multiplier = 5
    }
}

function herbalistSystem.onUse(cid, item, fromPosition, itemEx, toPosition)
    local player = Player(cid)
    if not player then
        return true
    end
    
    local lastUsageTime = player:getStorageValue(215554) 

    if os.time() - lastUsageTime < COOLDOWN_SECONDS then
        player:sendTextMessage(MESSAGE_INFO_DESCR, "You must wait a few seconds before using the scissor's again.")
        return true
    end

    local object = config[itemEx.itemid]
    if object then
        if object.text then
            playSound(player, "herbalist_fail.ogg")
            local rand_text = math.random(#object.text)
            doCreatureSay(cid, object.text[rand_text], TALKTYPE_ORANGE_1, nil, nil, toPosition)
            SendMagicEffect(toPosition, 181)
            return true
        end
        
        local requiredSkill = object.requiredSkill or 0
        local playerSkill = player:getSkillLevel(SKILL_HERBALIST)

        if playerSkill < requiredSkill then
            player:sendTextMessage(MESSAGE_INFO_DESCR, "You don't have the required herbalist skill to harvest on this plant.")
            return true
        end
        player:setNoMove(true)
            addEvent(function()
                player:setNoMove(false)
          end, 2300)
        local skillMultiplier = 1 

        for _, stage in ipairs(skillsStages) do
            if playerSkill >= stage.minlevel then
                if not stage.maxlevel or playerSkill <= stage.maxlevel then
                    skillMultiplier = stage.multiplier
                    break
                end
            end
        end
        toPosition.y = toPosition.y + 1
        toPosition.x = toPosition.x + 1

        SendMagicEffect(toPosition, 194)  
        SendMagicEffect(player:getPosition(), 176) 
        playSound(player, "herbalist.ogg")
        addEvent(function()
            local rand_event = math.random(200)
            if rand_event == 200 then
                SendMagicEffect(toPosition, 181)
                return true
            end

            local rand_break = math.random(100)
            if rand_break <= object.break_chance then
                doTransformItem(itemEx.uid, object.lower_tier)
                SendMagicEffect(toPosition, 181)
                local transformedItem = Item(itemEx.uid)
                transformedItem:decay()
            end

            local rand_reward = math.random(100)
            if rand_reward > (object.loot_chance + 10) then
                SendMagicEffect(toPosition, 181)
                return true
            end

            local multiple = 1
            local rand_multiple = math.random(15)
            if rand_multiple == 15 then
                multiple = math.random(2, 3)
            end
            for i = 1, multiple do
                local loot_table = object.normal_loot_table
                local rand_loot = (_G.ProfessionMastery_rollRareFind and _G.ProfessionMastery_rollRareFind(player, "herbalist")) and 1 or math.random(100)
                if rand_loot < 6 then
                    loot_table = object.rare_loot_table
                elseif rand_loot < 21 then
                    loot_table = object.semi_rare_loot_table
                end
                local rand_item = math.random(#loot_table)
                rand_item = loot_table[rand_item]
                if rand_item.count == 1 then
                    doPlayerAddItem(cid, rand_item.item_id, _G.ProfessionMastery_adjustRewardCount and _G.ProfessionMastery_adjustRewardCount(player, "herbalist", 1) or 1, true)
                else
                    local new_count = math.random(rand_item.count)
                    doPlayerAddItem(cid, rand_item.item_id, _G.ProfessionMastery_adjustRewardCount and _G.ProfessionMastery_adjustRewardCount(player, "herbalist", new_count) or new_count, true)
                end
              end
              if _G.ProfessionMastery_onGather then
                  _G.ProfessionMastery_onGather(player, "herbalist")
              end
              local skillTries = math.floor(skillMultiplier)
              if _G.GuildProfession_onActivity then
                  _G.GuildProfession_onActivity(player, "herbalist", 1)
              end
              if _G.TriCraftGem_onProfessionActivity then
                  _G.TriCraftGem_onProfessionActivity(player, "herbalist", 1)
              end
              player:addSkillTries(SKILL_HERBALIST, skillTries)
        end, 3000)  
    else
        player:say("This shears cannot harvest this plant.", TALKTYPE_MONSTER_SAY)

    end
    player:setStorageValue(215554, os.time())
    return true
end

herbalistSystem:id(30379)
herbalistSystem:register()
