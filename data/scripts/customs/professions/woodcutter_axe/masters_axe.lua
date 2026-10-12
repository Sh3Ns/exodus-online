local woodcutterSystem = Action()
local COOLDOWN_SECONDS = 4

local config = {
    [26604] = {text = {"Ash Tree is regenerating"}}, 
    [26605] = {break_chance = 75, loot_chance = 80, lower_tier = 26604, requiredSkill = 5, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 26595, count = 1}, 
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 26595, count = 2}, 
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 26595, count = 4},
        },
    },
    [26606] = {break_chance = 75, loot_chance = 80, lower_tier = 26605, requiredSkill = 5, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 26595, count = 1}, 
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 26595, count = 2}, 
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 26595, count = 4},
        },
    },
    [26636] = {text = {"Small Tree is regenerating"}}, 
    [26635] = {break_chance = 75, loot_chance = 80, lower_tier = 26636, requiredSkill = 0, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 26593, count = 1}, 
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 26594, count = 2}, 
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 26593, count = 4},
        },
    },
    [26634] = {break_chance = 75, loot_chance = 80, lower_tier = 26635, requiredSkill = 0, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 26593, count = 1}, 
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 26594, count = 2}, 
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 26593, count = 4},
        },
    },
    [26612] = {text = {"Chestnut Tree is regenerating"}}, 
    [26611] = {break_chance = 75, loot_chance = 80, lower_tier = 26612, requiredSkill = 15, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 26596, count = 1}, 
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 26596, count = 2}, 
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 26596, count = 4},
        },
    },
    [26610 ] = {break_chance = 75, loot_chance = 80, lower_tier = 26611, requiredSkill = 15, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 26596, count = 1}, 
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 26596, count = 2}, 
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 26596, count = 4},
        },
    },
    [26615] = {text = {"Olive Tree is regenerating"}}, 
    [26614] = {break_chance = 75, loot_chance = 80, lower_tier = 26615, requiredSkill = 20, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 26598, count = 1}, 
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 26598, count = 2}, 
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 26598, count = 4},
        },
    },
    [26613 ] = {break_chance = 75, loot_chance = 80, lower_tier = 26614, requiredSkill = 20, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 26598, count = 1}, 
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 26598, count = 2}, 
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 26598, count = 4},
        },
    },
    [26607] = {text = {"Cherry Tree is regenerating"}}, 
    [26608] = {break_chance = 75, loot_chance = 80, lower_tier = 26607, requiredSkill = 30, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 26597, count = 1}, 
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 26597, count = 2}, 
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 26597, count = 4},
        },
    },
    [26609 ] = {break_chance = 75, loot_chance = 80, lower_tier = 26608, requiredSkill = 30, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 26597, count = 1}, 
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 26597, count = 2}, 
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 26597, count = 4},
        },
    },
    [30144] = {text = {"Verdant tree is regenerating"}},
    [30143] = {break_chance = 55, loot_chance = 80, lower_tier = 30144, requiredSkill = 50,
        normal_loot_table = { -- 80%
            [1] = {item_id = 30225, count = 2},
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 30225, count = 3},
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 30225, count = 6},
        },
    },
    [30173] = {text = {"Grimwood is regenerating"}},
    [30172] = {break_chance = 66, loot_chance = 80, lower_tier = 30173, requiredSkill = 50,
        normal_loot_table = { -- 80%
            [1] = {item_id = 30239, count = 2},
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 30239, count = 3},
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 30239, count = 6},
        },
    },
    [30175] = {text = {"Duskwillow is regenerating"}},
    [30174] = {break_chance = 66, loot_chance = 80, lower_tier = 30175, requiredSkill = 50,
        normal_loot_table = { -- 80%
            [1] = {item_id = 30240, count = 2},
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 30240, count = 3},
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 30240, count = 6},
        },
    },
    [30177] = {text = {"Gildedheart is regenerating"}},
    [30176] = {break_chance = 66, loot_chance = 80, lower_tier = 30177, requiredSkill = 50,
        normal_loot_table = { -- 80%
            [1] = {item_id = 30241, count = 2},
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 30241, count = 3},
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 30241, count = 6},
        },
    },
    [30179] = {text = {"Cinderbark is regenerating"}},
    [30178] = {break_chance = 66, loot_chance = 80, lower_tier = 30179, requiredSkill = 50,
        normal_loot_table = { -- 80%
            [1] = {item_id = 30242, count = 2},
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 30242, count = 3},
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 30242, count = 6},
        },
    },
    [30181] = {text = {"Frostpine is regenerating"}},
    [30180] = {break_chance = 66, loot_chance = 80, lower_tier = 30181, requiredSkill = 50,
        normal_loot_table = { -- 80%
            [1] = {item_id = 30243, count = 2},
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 30243, count = 3},
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 30243, count = 6},
        },
    },
    [30213] = {text = {"Verdwood is regenerating"}},
    [30212] = {break_chance = 75, loot_chance = 80, lower_tier = 30213, requiredSkill = 50,
        normal_loot_table = { -- 80%
            [1] = {item_id = 30267, count = 1},
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 30267, count = 2},
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 30267, count = 3},
        },
    },
    [30215] = {text = {"Sylvan is regenerating"}},
    [30214] = {break_chance = 75, loot_chance = 80, lower_tier = 30215, requiredSkill = 50,
        normal_loot_table = { -- 80%
            [1] = {item_id = 30268, count = 1},
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 30268, count = 2},
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 30268, count = 3},
        },
    },
    [30217] = {text = {"Aurawood is regenerating"}},
    [30216] = {break_chance = 75, loot_chance = 80, lower_tier = 30217, requiredSkill = 50,
        normal_loot_table = { -- 80%
            [1] = {item_id = 30269, count = 1},
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 30269, count = 2},
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 30269, count = 3},
        },
    },
    [30219] = {text = {"Umbrabloom is regenerating"}},
    [30218] = {break_chance = 80, loot_chance = 80, lower_tier = 30219, requiredSkill = 50,
        normal_loot_table = { -- 80%
            [1] = {item_id = 30270, count = 1},
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 30270, count = 2},
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 30270, count = 3},
        },
    },
    [30221] = {text = {"Bloodwood is regenerating"}},
    [30220] = {break_chance = 85, loot_chance = 80, lower_tier = 30221, requiredSkill = 50,
        normal_loot_table = { -- 80%
            [1] = {item_id = 30271, count = 1},
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 30271, count = 2},
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 30271, count = 3},
        },
    },
}

_G.ProfessionGatheringResources = _G.ProfessionGatheringResources or {}
for resourceId, resourceData in pairs(config) do
    if resourceData.lower_tier then
        _G.ProfessionGatheringResources[resourceId] = {
            profession = "woodcutting",
            skill = SKILL_WOODCUTTING,
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


function woodcutterSystem.onUse(cid, item, fromPosition, itemEx, toPosition)
    local player = Player(cid)
    if not player then
        return true
    end
    
    local lastUsageTime = player:getStorageValue(215563) 

    if os.time() - lastUsageTime < COOLDOWN_SECONDS then
        player:sendTextMessage(MESSAGE_INFO_DESCR, "You must wait a few seconds before using the axe again.")
        return true
    end

    local object = config[itemEx.itemid]
    if object then
        if object.text then
            playSound(player, "woodcutting_fail.ogg")
            local rand_text = math.random(#object.text)
            doCreatureSay(cid, object.text[rand_text], TALKTYPE_ORANGE_1, nil, nil, toPosition)
            SendMagicEffect(toPosition, 181)
            return true
        end
        
        local requiredSkill = object.requiredSkill or 0
        local playerSkill = player:getSkillLevel(SKILL_WOODCUTTING)

        if playerSkill < requiredSkill then
            player:sendTextMessage(MESSAGE_INFO_DESCR, "You don't have the required woodcutter skill to cut this tree.")
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
        SendMagicEffect(toPosition, 180)  
        SendMagicEffect(player:getPosition(), 176) 
        playSound(player, "woodcutting.ogg")
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
                local rand_loot = (_G.ProfessionMastery_rollRareFind and _G.ProfessionMastery_rollRareFind(player, "woodcutting")) and 1 or math.random(100)
                if rand_loot < 6 then
                    loot_table = object.rare_loot_table
                elseif rand_loot < 21 then
                    loot_table = object.semi_rare_loot_table
                end
                local rand_item = math.random(#loot_table)
                rand_item = loot_table[rand_item]
                if rand_item.count == 1 then
                    doPlayerAddItem(cid, rand_item.item_id, _G.ProfessionMastery_adjustRewardCount and _G.ProfessionMastery_adjustRewardCount(player, "woodcutting", 1) or 1, true)
                else
                    local new_count = math.random(rand_item.count)
                    doPlayerAddItem(cid, rand_item.item_id, _G.ProfessionMastery_adjustRewardCount and _G.ProfessionMastery_adjustRewardCount(player, "woodcutting", new_count) or new_count, true)
                end
              end
              if _G.ProfessionMastery_onGather then
                  _G.ProfessionMastery_onGather(player, "woodcutting")
              end
              local skillTries = math.floor(skillMultiplier)
              if _G.GuildProfession_onActivity then
                  _G.GuildProfession_onActivity(player, "woodcutting", 1)
              end
              if _G.TriCraftGem_onProfessionActivity then
                  _G.TriCraftGem_onProfessionActivity(player, "woodcutting", 1)
              end
              player:addSkillTries(SKILL_WOODCUTTING, skillTries)
        end, 3000)  
    else
        player:say("This axe cannot cut on this tree.", TALKTYPE_MONSTER_SAY)


    end
    player:setStorageValue(215563, os.time())
    return true
end

woodcutterSystem:id(30389)
woodcutterSystem:register()
