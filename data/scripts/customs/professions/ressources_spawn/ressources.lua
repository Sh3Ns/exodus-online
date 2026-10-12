--- I Do not recommend use another one for other Floors Like 8 or any others, because they can spawn an stuck on a One tile SQM passage. Floor 7 is ok.

local spawnTree = GlobalEvent("ressourcesSpawn")
local itemsList = { 
    {itemId = 26634, quantity = 350},
    {itemId = 26606, quantity = 350},
    {itemId = 26610, quantity = 300},
    {itemId = 26613, quantity = 300},
    {itemId = 26609, quantity = 200},
    {itemId = 26405, quantity = 350},
    {itemId = 26406, quantity = 350},
    {itemId = 26407, quantity = 300},
    {itemId = 26411, quantity = 300},
    {itemId = 26410, quantity = 300},
    {itemId = 26408, quantity = 200},
    {itemId = 26409, quantity = 200},
    {itemId = 26717, quantity = 350},
    {itemId = 26718, quantity = 350},
    {itemId = 26719, quantity = 300},
    {itemId = 26720, quantity = 300},
    {itemId = 26721, quantity = 200},
    {itemId = 26722, quantity = 200}
}

local forbiddenSpawn = {
    [6216] = true,
    [6217] = true,
    [6218] = true,
    [6219] = true,
    [3613] = true,
    [3650] = true,
    [3610] = true,
    [26405] = true,
    [26406] = true,
    [26407] = true,
    [26408] = true,
    [26409] = true,
    [26410] = true,
    [26411] = true,
    [26604] = true,
    [26605] = true,
    [26606] = true,
    [26607] = true,
    [26608] = true,
    [26609] = true,
    [26610] = true,
    [26611] = true,
    [26612] = true,
    [26613] = true,
    [26614] = true,
    [26615] = true,
    [26634] = true,
    [26635] = true,
    [26636] = true,
    [26717] = true,
    [26718] = true,
    [26719] = true,
    [26720] = true,
    [26721] = true,
    [26722] = true,
    [26723] = true,
    [26724] = true,
    [10740] = true,
    [10741] = true,
    [10742] = true,
    [8223] = true,
    [8221]  = true,
    [8222] = true,
    [8393] = true,
    [8399] = true,

}

local allowedGrounds = {
    [8326] = true,
    [8327] = true,
    [8328] = true,
    [8329] = true,
    [8330] = true,
    [8331] = true,
    [8332] = true,
    [8333] = true,
    [8334] = true,
    [8347] = true,
    [8348] = true,
    [4526] = true,
    [4527] = true,
    [4528] = true,
    [4529] = true,
    [4530] = true,
    [4531] = true,
    [4532] = true,
    [4533] = true,
    [4534] = true,
    [4535] = true,
    [4536] = true,
    [4537] = true,
    [4538] = true,
    [4539] = true,
    [4540] = true,
    [4541] = true,
    [6580] = true,
    [6581] = true,
    [6582] = true,
    [6583] = true,
    [6584] = true,
    [6585] = true,
    [6586] = true,
    [6587] = true,
    [6588] = true,
    [6589] = true,
    [6590] = true,
    [6591] = true,
    [6592] = true,
    [6593] = true,
    [10441] = true,
    [10442] = true,
    [10443] = true,
    [10444] = true,
    [10445] = true,
    [10446] = true,
    [10447] = true,
    [10448] = true,
    [10617] = true,
    [10618] = true,
    [10619] = true,
    [10620] = true,
    [10621] = true,
    [10622] = true,
    [10623] = true,
    [10624] = true,
    [11504] = true,
    [11490] = true,
    [11491] = true,
    [3264] = true,
    [3265] = true,
    [3263] = true,
    [25004] = true,
    [25005] = true,
    [25006] = true,
    [25007] = true,
    [25008] = true,
    [25009] = true,
    [25010] = true,
    [25011] = true,
    [25012] = true,
    [25013] = true,
    [25014] = true,
    [17665] = true,
    [17666] = true,
    [17667] = true,
    [17668] = true,
    [17669] = true,
    [17670] = true,
    [17671] = true,
    [17672] = true,
    [21605] = true,
    [21606] = true,
    [21607] = true,
    [21608] = true,
    [21609] = true,
    [21610] = true,
    [21611] = true,
    [21612] = true,
    [670] = true,
    [28718] = true,
    [28719] = true,
    [28720] = true,
    [28721] = true,
    [29018] = true,
    [28919] = true,
    [29153] = true,
    [29178] = true,

}

local STARTUP = {}
local spawnedCount = {}
local MAX_ATTEMPTS = 10000

STARTUP[#STARTUP + 1] = {
    action = function()
        for _, item in ipairs(itemsList) do
            spawnedCount[item.itemId] = 0
        end
        local fromPos = {x= 30562, y=30822, z=7}
        local toPos = {x = 33755, y = 33670, z = 7}
        for _, item in ipairs(itemsList) do
            local spawned = 0
            local attempts = 0

            while spawned < item.quantity and attempts < MAX_ATTEMPTS do
                attempts = attempts + 1

                local pos = {
                    x = math.random(fromPos.x, toPos.x),
                    y = math.random(fromPos.y, toPos.y),
                    z = fromPos.z
                }

                local tile = Tile(pos)
                if tile then
                    local ground = tile:getGround()
                    if ground then
                        local groundId = ground:getId()
                        if (groundId >= 9043 and groundId <= 9058) or allowedGrounds[groundId] then
                            local invalid = false

                            for _, thing in ipairs(tile:getItems() or {}) do
                                if forbiddenSpawn[thing:getId()] then
                                    invalid = true
                                    break
                                end
                            end

                            if not invalid then
                                local tileInfo = getTileInfo(pos)
                                if tileInfo.items == 0 and tileInfo.creatures == 0 then
                                    doCreateItem(item.itemId, 1, pos)
                                    spawned = spawned + 1
                                    spawnedCount[item.itemId] = spawned
                                end
                            end
                        end
                    end
                end
            end
            --- Part for check if area is saturated, because there is many restrictions tiles for spawn. Uncommented, only for tests.
            -- if spawned < item.quantity then
            --     print(string.format(
            --         "[Resources Spawn][WARNING] Item %d spawned only %d / %d (area saturated)",
            --         item.itemId, spawned, item.quantity
            --     ))
            -- end
        end
    end
}

function spawnTree.onStartup()
    for _, cmd in pairs(STARTUP) do
        cmd.action()
    end

    addEvent(function()
        print("[Resources Spawn] ===== Creating Resources on the World =====")
        for _, item in ipairs(itemsList) do
            local spawned = spawnedCount[item.itemId] or 0
            local name = ItemType(item.itemId):getName()
            print(string.format(
                "[Resources Spawn] %s (%d) spawned: %d / %d",
                name,
                item.itemId,
                spawned,
                item.quantity
            ))
        end
        print("[Resources Spawn] =========================")
    end, 2500)

    STARTUP = nil
    return true
end

spawnTree:register()