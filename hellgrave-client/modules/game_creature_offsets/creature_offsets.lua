-- X: negative = left, positive = right
-- Y: negative = up,   positive = down

local defaultOffset = {
  [North] = { x = 0, y = 0 },
  [East] = { x = 0, y = 0 },
  [South] = { x = 0, y = 0 },
  [West] = { x = 0, y = 0 }
}

local creatureOffsets = {
  [1110] = {
    [North] = { x = 25, y = 32 },
    [East]  = { x = 32, y = 25 },
    [South] = { x = 25, y = 32 },
    [West]  = { x = 32, y = 25 }
  },
  [1111] = {
    [North] = { x = 6, y = 50 },
    [East]  = { x = 50, y = 6 },
    [South] = { x = 6, y = 50 },
    [West]  = { x = 50, y = 6 }
  },
  [1112] = {
    [North] = { x = 25, y = 32 },
    [East]  = { x = 32, y = 25 },
    [South] = { x = 25, y = 32 },
    [West]  = { x = 32, y = 25 }
  },
  [1113] = {
    [North] = { x = 15, y = 20 },
    [East]  = { x = 20, y = 15 },
    [South] = { x = 15, y = 20 },
    [West]  = { x = 20, y = 15 }
  },
  [1114] = {
    [North] = { x = 25, y = 32 },
    [East]  = { x = 32, y = 25 },
    [South] = { x = 25, y = 32 },
    [West]  = { x = 32, y = 25 }
  },
  [1115] = {
    [North] = { x = 25, y = 32 },
    [East]  = { x = 32, y = 25 },
    [South] = { x = 25, y = 32 },
    [West]  = { x = 32, y = 25 }
  },
  [1116] = {
    [North] = { x = 25, y = 32 },
    [East]  = { x = 32, y = 25 },
    [South] = { x = 25, y = 32 },
    [West]  = { x = 32, y = 25 }
  },
  [1167] = {
    [North] = { x = 15, y = 15 },
    [East]  = { x = 15, y = 15 },
    [South] = { x = 15, y = 15 },
    [West]  = { x = 15, y = 15 }
  },
  [1168] = {
    [North] = { x = 15, y = 15 },
    [East]  = { x = 15, y = 15 },
    [South] = { x = 15, y = 15 },
    [West]  = { x = 15, y = 15 }
  },
  [1132] = {
    [North] = { x = 27, y = 3 },
    [East]  = { x = 3, y = 27 },
    [South] = { x = 27, y = 3 },
    [West]  = { x = 3, y = 27 }
  },
  [1133] = {
    [North] = { x = 12, y = 8 },
    [East]  = { x = 8, y = 12 },
    [South] = { x = 12, y = 8 },
    [West]  = { x = 8, y = 12 }
  },
  [1134] = {
    [North] = { x = 16, y = 8 },
    [East]  = { x = 8, y = 16 },
    [South] = { x = 16, y = 8 },
    [West]  = { x = 8, y = 16 }
  },
  [1135] = {
    [North] = { x = 28, y = 28 },
    [East]  = { x = 28, y = 28 },
    [South] = { x = 28, y = 28 },
    [West]  = { x = 28, y = 28 }
  },
  [1136] = {
    [North] = { x = 25, y = 25 },
    [East]  = { x = 25, y = 25 },
    [South] = { x = 25, y = 25 },
    [West]  = { x = 25, y = 25 }
  },
  [1403] = {
    [North] = { x = 32, y = 8 },
    [East]  = { x = 8, y = 32 },
    [South] = { x = 32, y = 8 },
    [West]  = { x = 8, y = 32 }
  },
  [1496] = {
    [North] = { x = 15, y = 8 },
    [East]  = { x = 8, y = 15 },
    [South] = { x = 15, y = 8 },
    [West]  = { x = 8, y = 15 }
  },
  [1498] = {
    [North] = { x = 15, y = 8 },
    [East]  = { x = 8, y = 15 },
    [South] = { x = 15, y = 8 },
    [West]  = { x = 8, y = 15 }
  },
  [1499] = {
    [North] = { x = 15, y = 8 },
    [East]  = { x = 8, y = 15 },
    [South] = { x = 15, y = 8 },
    [West]  = { x = 8, y = 15 }
  },
  [1500] = {
    [North] = { x = 20, y = 10 },
    [East]  = { x = 10, y = 20 },
    [South] = { x = 20, y = 10 },
    [West]  = { x = 10, y = 20 }
  },
  [1501] = {
    [North] = { x = 15, y = 0 },
    [East]  = { x = 8, y = 15 },
    [South] = { x = 15, y = 0 },
    [West]  = { x = 8, y = 15 }
  },
  [1502] = {
    [North] = { x = 20, y = 10 },
    [East]  = { x = 10, y = 20 },
    [South] = { x = 20, y = 10 },
    [West]  = { x = 10, y = 20 }
  },
  [1503] = {
    [North] = { x = 15, y = 0 },
    [East]  = { x = 8, y = 15 },
    [South] = { x = 15, y = 0 },
    [West]  = { x = 8, y = 15 }
  },
  [1504] = {
    [North] = { x = 16, y = 10 },
    [East] = { x = 20, y = 18 },
    [South] = { x = 19, y = 25 },
    [West] = { x = 16, y = 16 }
  },
  [1505] = {
    [North] = { x = 12, y = 20 },
    [East] = { x = 20, y = 18 },
    [South] = { x = 19, y = 12 },
    [West] = { x = 20, y = 12 }
  },
  [1506] = {
    [North] = { x = 12, y = 20 },
    [East] = { x = 20, y = 12 },
    [South] = { x = 16, y = 12 },
    [West] = { x = 20, y = 10 }
  },
  [1507] = {
    [North] = { x = 12, y = 20 },
    [East] = { x = 16, y = 12 },
    [South] = { x = 16, y = 12 },
    [West] = { x = 20, y = 6 }
  },
  [1508] = {
    [North] = { x = 12, y = 20 },
    [East] = { x = 20, y = 18 },
    [South] = { x = 19, y = 12 },
    [West] = { x = 20, y = 12 }
  },
  [1509] = {
    [North] = { x = 12, y = 20 },
    [East] = { x = 10, y = 12 },
    [South] = { x = 20, y = 12 },
    [West] = { x = 30, y = 12 }
  },
  [1510] = {
    [North] = { x = 12, y = 20 },
    [East] = { x = 16, y = 18 },
    [South] = { x = 19, y = 12 },
    [West] = { x = 20, y = 12 }
  },
  [1511] = {
    [North] = { x = 12, y = 20 },
    [East] = { x = 20, y = 18 },
    [South] = { x = 19, y = 12 },
    [West] = { x = 20, y = 12 }
  },


  -- X: negative = left, positive = right
  -- Y: negative = up,   positive = down
  --- You can add here creatures, if you wanted to move creature and see the Red square of attacking a creature to be more in "middle of the creature"
}

local caravanLookTypes = {
  [1504] = true,
  [1505] = true,
  [1506] = true,
  [1507] = true,
  [1508] = true,
  [1509] = true,
  [1510] = true,
  [1511] = true,
}

local function isCaravanCreature(creature)
  if not creature then
    return false
  end

  local outfit = creature:getOutfit()
  local lookType = outfit and outfit.type or 0
  return caravanLookTypes[lookType] == true
end

local function localPlayerHasWings()
  local player = g_game.getLocalPlayer()
  if not player then
    return false
  end

  local outfit = player:getOutfit()
  if not outfit then
    return false
  end

  return (outfit.wings or outfit.lookWings or 0) > 0
end

local function updateCaravanFloating(creature)
  if not creature or not creature.setFloating then
    return
  end

  if not isCaravanCreature(creature) then
    creature:setFloating(false)
    return
  end

  creature:setFloating(localPlayerHasWings())
end

local function refreshVisibleCaravanFloating()
  local player = g_game.getLocalPlayer()
  if not player then
    return
  end

  for _, creature in ipairs(g_map.getSpectators(player:getPosition(), false)) do
    updateCaravanFloating(creature)
  end
end

local function translateDir(dir)
  if dir == NorthEast or dir == SouthEast then
    return East
  elseif dir == NorthWest or dir == SouthWest then
    return West
  end
  return dir
end

local function getCreatureOutfitId(creature)
  local outfit = creature:getOutfit()
  return outfit and outfit.type or 0
end

local function getOffsetByOutfitId(outfitId, dir)
  local offsets = creatureOffsets[outfitId]
  if not offsets then
    return defaultOffset[South]
  end
  return offsets[translateDir(dir)] or defaultOffset[South]
end

local function applyCreatureOffset(creature, dir, outfitId)
  if creature:isPlayer() then
    creature:setOutfitOffset(0, 0)
    return
  end

  outfitId = outfitId or getCreatureOutfitId(creature)
  local offset = getOffsetByOutfitId(outfitId, dir or creature:getDirection())
  creature:setOutfitOffset(offset.x, offset.y)
end

local function scheduleCreatureOffsetRefresh(creature)
  for _, delay in ipairs({ 50, 150, 300 }) do
    scheduleEvent(function()
      if creature and not creature:isWalking() then
        applyCreatureOffset(creature)
      end
    end, delay)
  end
end

local function onCreatureAppear(creature)
  applyCreatureOffset(creature)
  updateCaravanFloating(creature)
  scheduleCreatureOffsetRefresh(creature)
end

local function onCreatureDirectionChange(creature, oldDirection, newDirection)
  applyCreatureOffset(creature, newDirection)
  updateCaravanFloating(creature)
end

local function onCreatureOutfitChange(creature, newOutfit, oldOutfit)
  local outfitId = newOutfit and newOutfit.type or getCreatureOutfitId(creature)
  applyCreatureOffset(creature, creature:getDirection(), outfitId)
  updateCaravanFloating(creature)
  scheduleCreatureOffsetRefresh(creature)
end

local function onLocalPlayerPositionChange(player, newPos, oldPos)
  scheduleEvent(function()
    if player and not player:isWalking() then
      applyCreatureOffset(player)
    end
  end, 50)
end

local function onLocalPlayerWalkFinish(player)
  applyCreatureOffset(player)
end

local function resetVisibleCreatureOffsets()
  local player = g_game.getLocalPlayer()
  if not player then
    return
  end

  for _, creature in ipairs(g_map.getSpectators(player:getPosition(), false)) do
    creature:setOutfitOffset(0, 0)

    if creature.setFloating then
      creature:setFloating(false)
    end
  end
end

local function onLocalPlayerOutfitChange(player, newOutfit, oldOutfit)
  refreshVisibleCaravanFloating()
end

function init()
  connect(Creature, {
    onAppear = onCreatureAppear,
    onDirectionChange = onCreatureDirectionChange,
    onOutfitChange = onCreatureOutfitChange
  })

  connect(LocalPlayer, {
    onPositionChange = onLocalPlayerPositionChange,
    onWalkFinish = onLocalPlayerWalkFinish,
    onOutfitChange = onLocalPlayerOutfitChange
  })

  local player = g_game.getLocalPlayer()
  if player then
    for _, creature in ipairs(g_map.getSpectators(player:getPosition(), false)) do
      applyCreatureOffset(creature)
      updateCaravanFloating(creature)
    end
  end

  refreshVisibleCaravanFloating()
end

function terminate()
  disconnect(Creature, {
    onAppear = onCreatureAppear,
    onDirectionChange = onCreatureDirectionChange,
    onOutfitChange = onCreatureOutfitChange
  })

  disconnect(LocalPlayer, {
    onPositionChange = onLocalPlayerPositionChange,
    onWalkFinish = onLocalPlayerWalkFinish,
    onOutfitChange = onLocalPlayerOutfitChange
  })

  resetVisibleCreatureOffsets()
end