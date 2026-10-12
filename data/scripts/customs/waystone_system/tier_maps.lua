local OPCODE      = 202
local TeleportTiming = 60 * 1000 --- Time to remove Teleports after creation 60s
local OccupyDuration   = 30 * 60 * 1000  -- 30 minutes until kick
local CooldownStorage  = 557184 --- Storage Cooldown
local PAD_AID = 46201

print(">> Waystone System Loaded")

local VISUAL1_STORAGE = 139754
local VISUAL2_STORAGE = 139755
local VISUAL3_STORAGE = 139756
local VISUAL4_STORAGE = 139757
local VISUAL5_STORAGE = 139758
local VISUAL6_STORAGE = 139759
local VISUAL7_STORAGE = 139760
local VISUAL8_STORAGE = 139761
local VISUAL9_STORAGE = 139762
local VISUAL10_STORAGE = 139763
local VISUAL11_STORAGE = 139764
local VISUAL12_STORAGE = 139765
local VISUAL13_STORAGE = 139766

local SELECTED_STORAGE = 238754

local clientToServer = { --- Client ID -> Item ID ( Tier Tablets )
  [27189] = 29845, -- Tier I
  [27190] = 29846,
  [27191] = 29847,
  [27192] = 29848,
  [27193] = 29849,
  [27194] = 29850, -- Tier VI
}

local teleportMapping = {
  [29845] = {
    { ---- Underground: Map 3 Water
      area = {
        fromPos = Position(33314, 33066, 8),
        toPos   = Position(33606, 33178, 8),
        exitPos = Position(32369, 32241, 7)
      },
      destination = Position(33597, 33141, 8)
    },
    { ---- Floor: Map 6 Cave
      area = {
        fromPos = Position(32848, 33353, 7),
        toPos   = Position(33096, 33506, 7),
        exitPos = Position(32369, 32241, 7)
      },
      destination = Position(32877, 33496, 7)
    },
  },
  [29846] = {
    { ---- Floor: Map 2
      area = {
        fromPos = Position(33294, 32984, 7),
        toPos   = Position(33463, 33140, 7),
        exitPos = Position(32369, 32241, 7)
      },
      destination = Position(33324, 33069, 7)
    },
    { ---- Underground: Map 2 Cave
      area = {
        fromPos = Position(33100, 33083, 8),
        toPos   = Position(33281, 33215, 8),
        exitPos = Position(32369, 32241, 7)
      },
      destination = Position(33258, 33117, 8)
    },
  },
  [29847] = {
    { ---- Floor: Map 3
      area = {
        fromPos = Position(32847, 33173, 7),
        toPos   = Position(33067, 33294, 7),
        exitPos = Position(32369, 32241, 7)
      },
      destination = Position(33047, 33229, 7)
    },
    { ---- Underground: Map 1 Cave
      area = {
        fromPos = Position(32911, 33044, 8),
        toPos   = Position(33073, 33241, 8),
        exitPos = Position(32369, 32241, 7)
      },
      destination = Position(32994, 33159, 8)
    },
  },
  [29848] = {
    { ---- Floor: Map 4 (forest)
      area = {
        fromPos = Position(33112, 33168, 7),
        toPos   = Position(33303, 33308, 7),
        exitPos = Position(32369, 32241, 7)
      },
      destination = Position(33123, 33232, 7)
    },
    { ---- Underground: Map 5
      area = {
        fromPos = Position(33156, 33305, 8),
        toPos   = Position(33349, 33453, 8),
        exitPos = Position(32369, 32241, 7)
      },
      destination = Position(33197, 33332, 8)
    },
  },
  [29849] = {
    { ---- Floor: Map 5 (desert)
      area = {
        fromPos = Position(33351, 33170, 7),
        toPos   = Position(33556, 33356, 7),
        exitPos = Position(32369, 32241, 7)
      },
      destination = Position(33524, 33331, 7)
    },
    { ---- Floor: Map 1 (Ice)
      area = {
        fromPos = Position(32930, 32960, 7),
        toPos   = Position(33245, 33129, 7),
        exitPos = Position(32369, 32241, 7)
      },
      destination = Position(32956, 33030, 7)
    },
  },
  [29850] = {
    { ---- Underground: Map 4 Undead cave
      area = {
        fromPos = Position(32890, 33257, 8),
        toPos   = Position(33107, 33437, 8),
        exitPos = Position(32369, 32241, 7)
      },
      destination = Position(32976, 33353, 8)
    },
    { ---- Floor: Map 7 (forest & desert)
      area = {
        fromPos = Position(33124, 33376, 7),
        toPos   = Position(33395, 33582, 7),
        exitPos = Position(32369, 32241, 7)
      },
      destination = Position(33322, 33394, 7)
    },
  },
}


local function getPlayerPadId(player)
  local choice = player:getStorageValue(SELECTED_STORAGE)
  if choice == 1 and player:getStorageValue(VISUAL1_STORAGE) == 1 then
    return 29629
  elseif choice == 2 and player:getStorageValue(VISUAL2_STORAGE) == 1 then
    return 29630
  elseif choice == 3 and player:getStorageValue(VISUAL3_STORAGE) == 1 then
    return 29631
  elseif choice == 4 and player:getStorageValue(VISUAL4_STORAGE) == 1 then
    return 29632
  elseif choice == 5 and player:getStorageValue(VISUAL5_STORAGE) == 1 then
    return 29633
  elseif choice == 6 and player:getStorageValue(VISUAL6_STORAGE) == 1 then
    return 29634
  elseif choice == 7 and player:getStorageValue(VISUAL7_STORAGE) == 1 then
    return 29635
  elseif choice == 8 and player:getStorageValue(VISUAL8_STORAGE) == 1 then
    return 29636
  elseif choice == 9 and player:getStorageValue(VISUAL9_STORAGE) == 1 then
    return 29637
  elseif choice == 10 and player:getStorageValue(VISUAL10_STORAGE) == 1 then
    return 29638
  elseif choice == 11 and player:getStorageValue(VISUAL11_STORAGE) == 1 then
    return 29639
  elseif choice == 12 and player:getStorageValue(VISUAL12_STORAGE) == 1 then
    return 29640
  elseif choice == 13 and player:getStorageValue(VISUAL13_STORAGE) == 1 then
    return 29641
  end
  return 1387
end

local pendingTablet = {}
local pendingCenter = {}
local pendingPortals = {}

local function clearOldPads(guid)
  local list = pendingPortals[guid]
  if not list then return end
  for _, info in ipairs(list) do
    local tile = Tile(info.pos)
    if tile then
      local pad = tile:getItemById(info.padId)
      if pad then pad:remove() end
    end
  end
  pendingPortals[guid] = nil
end

local showTabletUI = Action()
function showTabletUI.onUse(player, runeItem, fromPosition, target, toPosition, isHotkey)
  if not fromPosition:getTile():getHouse() then
    player:sendTextMessage(MESSAGE_INFO_DESCR, "You may only use Waystone Portal inside a House.")
    return true
  end
  local guid = player:getGuid()
  pendingCenter[player:getGuid()] = toPosition
  pendingTablet[guid] = runeItem
  player:setStorageValue(138755, 1)
  player:sendExtendedOpcode(OPCODE, json.encode{ action = "show" })
  return true
end
showTabletUI:aid(42707)
showTabletUI:register()


local waystoneDeviceEvent = CreatureEvent("TeleportTablet")
function waystoneDeviceEvent.onExtendedOpcode(player, opcode, buffer)
  if opcode ~= OPCODE then return false end
  local data = json.decode(buffer)
  if not data or not data.action then return false end

  local guid = player:getGuid()

  if data.action == "choice" then
    local choices = {
      { id = 0, text = "Default Pad" }
    }
    if player:getStorageValue(VISUAL1_STORAGE) == 1 then
      table.insert(choices, { id = 1, text = "Stone Portal" })
    end
    if player:getStorageValue(VISUAL2_STORAGE) == 1 then
      table.insert(choices, { id = 2, text = "Gold Portal" })
    end
    if player:getStorageValue(VISUAL3_STORAGE) == 1 then
      table.insert(choices, { id = 3, text = "Blood Portal" })
    end
    if player:getStorageValue(VISUAL4_STORAGE) == 1 then
      table.insert(choices, { id = 4, text = "Poisonous Portal" })
    end
    if player:getStorageValue(VISUAL5_STORAGE) == 1 then
      table.insert(choices, { id = 5, text = "Maze Portal" })
    end
    if player:getStorageValue(VISUAL6_STORAGE) == 1 then
      table.insert(choices, { id = 6, text = "Royal Portal" })
    end
    if player:getStorageValue(VISUAL7_STORAGE) == 1 then
      table.insert(choices, { id = 7, text = "Demonic Portal" })
    end
    if player:getStorageValue(VISUAL8_STORAGE) == 1 then
      table.insert(choices, { id = 8, text = "Palace Portal" })
    end
    if player:getStorageValue(VISUAL9_STORAGE) == 1 then
      table.insert(choices, { id = 9, text = "Lion Portal" })
    end
    if player:getStorageValue(VISUAL10_STORAGE) == 1 then
      table.insert(choices, { id = 10, text = "Underwater Portal" })
    end
    if player:getStorageValue(VISUAL11_STORAGE) == 1 then
      table.insert(choices, { id = 11, text = "Divine Portal" })
    end
    if player:getStorageValue(VISUAL12_STORAGE) == 1 then
      table.insert(choices, { id = 12, text = "Inferno Portal" })
    end
    if player:getStorageValue(VISUAL13_STORAGE) == 1 then
      table.insert(choices, { id = 13, text = "Jade Portal" })
    end


    player:sendExtendedOpcode(OPCODE, json.encode{
      action  = "choice_show",
      choices = choices
    })
    return true
  end

  if data.action == "choice_apply" then
    local choiceId = tonumber(data.choiceId)
    if choiceId == nil then
      player:sendExtendedOpcode(OPCODE, json.encode{
        action = "choice_error",
        text   = "No choice specified."
      })
      return true
    end

    if choiceId == 0 then
      player:setStorageValue(SELECTED_STORAGE, 0)
      player:sendExtendedOpcode(OPCODE, json.encode{ action = "choice_done" })
      return true

    elseif choiceId == 1 and player:getStorageValue(VISUAL1_STORAGE) == 1 then
      player:setStorageValue(SELECTED_STORAGE, 1)
      player:sendExtendedOpcode(OPCODE, json.encode{ action = "choice_done" })
      return true

    elseif choiceId == 2 and player:getStorageValue(VISUAL2_STORAGE) == 1 then
      player:setStorageValue(SELECTED_STORAGE, 2)
      player:sendExtendedOpcode(OPCODE, json.encode{ action = "choice_done" })
      return true
    elseif choiceId == 3 and player:getStorageValue(VISUAL3_STORAGE) == 1 then
      player:setStorageValue(SELECTED_STORAGE, 3)
      player:sendExtendedOpcode(OPCODE, json.encode{ action = "choice_done" })
      return true
    elseif choiceId == 4 and player:getStorageValue(VISUAL4_STORAGE) == 1 then
      player:setStorageValue(SELECTED_STORAGE, 4)
      player:sendExtendedOpcode(OPCODE, json.encode{ action = "choice_done" })
      return true
    elseif choiceId == 5 and player:getStorageValue(VISUAL5_STORAGE) == 1 then
      player:setStorageValue(SELECTED_STORAGE, 5)
      player:sendExtendedOpcode(OPCODE, json.encode{ action = "choice_done" })
      return true
    elseif choiceId == 6 and player:getStorageValue(VISUAL6_STORAGE) == 1 then
      player:setStorageValue(SELECTED_STORAGE, 6)
      player:sendExtendedOpcode(OPCODE, json.encode{ action = "choice_done" })
      return true
    elseif choiceId == 7 and player:getStorageValue(VISUAL7_STORAGE) == 1 then
      player:setStorageValue(SELECTED_STORAGE, 7)
      player:sendExtendedOpcode(OPCODE, json.encode{ action = "choice_done" })
      return true
    elseif choiceId == 8 and player:getStorageValue(VISUAL8_STORAGE) == 1 then
      player:setStorageValue(SELECTED_STORAGE, 8)
      player:sendExtendedOpcode(OPCODE, json.encode{ action = "choice_done" })
      return true
    elseif choiceId == 9 and player:getStorageValue(VISUAL9_STORAGE) == 1 then
      player:setStorageValue(SELECTED_STORAGE, 9)
      player:sendExtendedOpcode(OPCODE, json.encode{ action = "choice_done" })
      return true
    elseif choiceId == 10 and player:getStorageValue(VISUAL10_STORAGE) == 1 then
      player:setStorageValue(SELECTED_STORAGE, 10)
      player:sendExtendedOpcode(OPCODE, json.encode{ action = "choice_done" })
      return true
    elseif choiceId == 11 and player:getStorageValue(VISUAL11_STORAGE) == 1 then
      player:setStorageValue(SELECTED_STORAGE, 11)
      player:sendExtendedOpcode(OPCODE, json.encode{ action = "choice_done" })
      return true
    elseif choiceId == 12 and player:getStorageValue(VISUAL12_STORAGE) == 1 then
      player:setStorageValue(SELECTED_STORAGE, 12)
      player:sendExtendedOpcode(OPCODE, json.encode{ action = "choice_done" })
      return true
    elseif choiceId == 13 and player:getStorageValue(VISUAL13_STORAGE) == 1 then
      player:setStorageValue(SELECTED_STORAGE, 13)  
      player:sendExtendedOpcode(OPCODE, json.encode{ action = "choice_done" })
      return true
    end

    player:sendExtendedOpcode(OPCODE, json.encode{
      action = "choice_error",
      text   = "You have not unlocked that visual portal."
    })
    return true
  end

  if data.action == "wrap" then
    local waystoneDevice = pendingTablet[guid]
    pendingTablet[guid] = nil

    if not waystoneDevice or not waystoneDevice:isItem() then
      player:sendExtendedOpcode(OPCODE, json.encode{
        action = "wrap_error",
        text   = "No Waystone selected to wrap."
      })
      return true
    end

    local tid = waystoneDevice:getId()
    if tid ~= 29624 and tid ~= 29626 then
      player:sendExtendedOpcode(OPCODE, json.encode{
        action = "wrap_error",
        text   = "That item cannot be wrapped."
      })
      return true
    end

    waystoneDevice:transform(29628)
    waystoneDevice:setActionId(0)

    player:sendExtendedOpcode(OPCODE, json.encode{ action = "wrap_done" })
    return true
  end

   if data.action == "teleport" then
    if not data.clientId then return false end

    local waystoneDevice = pendingTablet[guid]
    pendingTablet[guid] = nil

    local serverTypeId = clientToServer[data.clientId]
    if not serverTypeId then
      player:sendExtendedOpcode(OPCODE, json.encode{
        action = "teleport_error",
        text   = "Only Tier Tablets allowed."
      })
      return true
    end

    local options = teleportMapping[serverTypeId]
    if not options or #options == 0 then
      player:sendExtendedOpcode(OPCODE, json.encode{
        action = "teleport_error",
        text   = "No destinations configured."
      })
      return true
    end

    local removed = player:removeItem(serverTypeId, 1, -1, true)

    if not removed then
      player:sendExtendedOpcode(OPCODE, json.encode{
        action = "teleport_error",
        text   = "You must keep the tablet inside your backpack."
      })
      return true
    end

    clearOldPads(guid)
    pendingPortals[guid] = {}

    local tried = {}
    local finalChoice, finalArea, finalDest, finalExit

    for _ = 1, #options do
      local idx = math.random(#options)
      while tried[idx] do idx = math.random(#options) end
      tried[idx] = true

      local choice       = options[idx]
      local area         = choice.area
      local destPos      = choice.destination
      local exitPosition = area.exitPos

      local cx    = math.floor((area.fromPos.x + area.toPos.x) / 2)
      local cy    = math.floor((area.fromPos.y + area.toPos.y) / 2)
      local cz    = area.fromPos.z
      local halfX = math.ceil((area.toPos.x - area.fromPos.x) / 2)
      local halfY = math.ceil((area.toPos.y - area.fromPos.y) / 2)

      local occupied = false
      for _, spec in ipairs(Game.getSpectators(
          Position(cx, cy, cz),
          false, false,
          halfX, halfX, halfY, halfY
      )) do
        if spec:isPlayer() then
          occupied = true
          break
        end
      end

      if not occupied then
        finalChoice = choice
        finalArea   = area
        finalDest   = destPos
        finalExit   = exitPosition
        break
      end
    end

    if not finalChoice then
      player:sendExtendedOpcode(OPCODE, json.encode{
        action = "teleport_error",
        text   = "All areas are currently occupied. Please try again later."
      })
      return true
    end

    local center = pendingCenter[guid]
    pendingCenter[guid] = nil
    if not center then
    player:sendExtendedOpcode(OPCODE, json.encode{
      action = "teleport_error",
      text   = "Teleport cancelled."
    })
    return true
    end
    local padId  = getPlayerPadId(player)
    pendingCenter[guid] = nil
    local pPos   = player:getPosition()
    local dirs = {
    {  1,  1},
    {  1, -1},
    { -1,  1},
    { -1, -1},
    }

    for _, d in ipairs(dirs) do
      local spawnPos = Position(center.x + d[1], center.y + d[2], center.z)
      if not (spawnPos.x == pPos.x and spawnPos.y == pPos.y and spawnPos.z == pPos.z) then
        local tile = Tile(spawnPos)
        if tile then
          local tileHouse = tile:getHouse()
          if tileHouse and tileHouse:getOwnerGuid() == player:getGuid() and tile:isWalkable() then
            if Game.createItem(padId, 1, spawnPos) then
              local pad = Tile(spawnPos):getItemById(padId)
              pad:setDestination(finalDest)
              pad:setActionId(PAD_AID)
              table.insert(pendingPortals[guid], { pos = spawnPos, padId = padId })
              addEvent(function()
                local t = Tile(spawnPos)
                if t then
                  local it = t:getItemById(padId)
                  if it then
                    it:setActionId(0)
                    it:remove()
                    end
                end
              end, TeleportTiming)
            end
          end
        end
      end
    end

    if #pendingPortals[guid] == 0 then
      player:sendTextMessage(MESSAGE_INFO_DESCR,
        "There is no space in your house to spawn portals.")
      return true
    end

    if waystoneDevice and waystoneDevice:isItem() then
      local tid = waystoneDevice:getId()
      if tid == 29624 then
        waystoneDevice:transform(29625)
      elseif tid == 29626 then
        waystoneDevice:transform(29627)
      end

      addEvent(function()
        if waystoneDevice and waystoneDevice:isItem() then
          local rid = waystoneDevice:getId()
          if rid == 29625 then
            waystoneDevice:transform(29624)
          elseif rid == 29627 then
            waystoneDevice:transform(29626)
          end
        end
      end, TeleportTiming)
    end

    player:sendExtendedOpcode(OPCODE, json.encode{ action = "teleport_done" })
    local kcx    = math.floor((finalArea.fromPos.x + finalArea.toPos.x) / 2)
    local kcy    = math.floor((finalArea.fromPos.y + finalArea.toPos.y) / 2)
    local kcz    = finalArea.fromPos.z
    local khalfX = math.ceil((finalArea.toPos.x - finalArea.fromPos.x) / 2)
    local khalfY = math.ceil((finalArea.toPos.y - finalArea.fromPos.y) / 2)

    addEvent(function()
      for _, spec in ipairs(Game.getSpectators(
          Position(kcx, kcy, kcz),
          false, false,
          khalfX, khalfX, khalfY, khalfY
      )) do
        if spec:isPlayer() then
          local stored = spec:getStorageValue(CooldownStorage)
          if stored <= os.time() then
            spec:setStorageValue(CooldownStorage, os.time() + (OccupyDuration/1000))
            spec:getPosition():sendMagicEffect(CONST_ME_POFF)
            spec:teleportTo(finalExit, false)
            finalExit:sendMagicEffect(CONST_ME_TELEPORT)
            spec:sendTextMessage(MESSAGE_INFO_DESCR,
              "30 minutes are up—you're being kicked out!")
          end
        end
      end
    end, OccupyDuration)
    return true
  end
  return false
end

waystoneDeviceEvent:type("extendedopcode")
waystoneDeviceEvent:register()


local CooldownStorage = 557184
local AREAS = teleportMapping

local function isInsideTeleportArea(pos)
    for _, maps in pairs(AREAS) do
        for _, zone in ipairs(maps) do
            local a = zone.area
            if pos.x >= a.fromPos.x and pos.x <= a.toPos.x
            and pos.y >= a.fromPos.y and pos.y <= a.toPos.y
            and pos.z == a.fromPos.z then
                return true
            end
        end
    end
    return false
end

local exit = MoveEvent()

function exit.onStepOut(creature, item, position, fromPosition)
    local player = creature:getPlayer()
    if not player then return true end

    if isInsideTeleportArea(fromPosition) and not isInsideTeleportArea(player:getPosition()) then
        player:setStorageValue(CooldownStorage, -1)
    end

    return true
end
exit:aid(19844)
exit:register()

local entrance = MoveEvent()

function entrance.onStepIn(creature, item, position, fromPosition)
    return true
end

entrance:aid(19844)
entrance:register()


local entrance = MoveEvent()

function entrance.onStepIn(creature, item, position, fromPosition)
   local player = creature:getPlayer()
    if not player then return true end

    player:setStorageValue(CooldownStorage, os.time() + (OccupyDuration / 1000))
    player:sendTextMessage(MESSAGE_INFO_DESCR,
        "You've entered, your 30 minute timer begins now.")

    return true
end

entrance:aid(46201)
entrance:register()

local loginEvent = CreatureEvent("TeleportTabletLogin")
function loginEvent.onLogin(player)
  if not isInsideTeleportArea(player:getPosition()) then
      player:setStorageValue(CooldownStorage, -1)
  end
  player:registerEvent("TeleportTablet")
  return true
end
loginEvent:type("login")
loginEvent:register()