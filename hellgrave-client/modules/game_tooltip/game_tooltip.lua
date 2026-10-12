m_TooltipList = {}
m_TooltipFunction = {}

m_TooltipFunction.GameServerSendTooltip = 159
m_TooltipFunction.GameServerParseTooltip = 158

m_TooltipFunction.TOOLTIP_ATTRIBUTE_NONE = 0
m_TooltipFunction.TOOLTIP_ATTRIBUTE_ATTACK = 1
m_TooltipFunction.TOOLTIP_ATTRIBUTE_DEFENSE = 2
m_TooltipFunction.TOOLTIP_ATTRIBUTE_NAME = 3
m_TooltipFunction.TOOLTIP_ATTRIBUTE_WEIGHT = 4
m_TooltipFunction.TOOLTIP_ATTRIBUTE_ARMOR = 5
m_TooltipFunction.TOOLTIP_ATTRIBUTE_HITCHANCE = 6
m_TooltipFunction.TOOLTIP_ATTRIBUTE_SHOOTRANGE = 7
m_TooltipFunction.TOOLTIP_ATTRIBUTE_DURATION = 8
m_TooltipFunction.TOOLTIP_ATTRIBUTE_CHARGES = 9
m_TooltipFunction.TOOLTIP_ATTRIBUTE_FLUIDTYPE = 10
m_TooltipFunction.TOOLTIP_ATTRIBUTE_ATTACK_SPEED = 11
m_TooltipFunction.TOOLTIP_ATTRIBUTE_RESISTANCES = 12
m_TooltipFunction.TOOLTIP_ATTRIBUTE_STATS = 13
m_TooltipFunction.TOOLTIP_ATTRIBUTE_SKILL = 14
m_TooltipFunction.TOOLTIP_ATTRIBUTE_KEY = 15
m_TooltipFunction.TOOLTIP_ATTRIBUTE_TEXT = 16
m_TooltipFunction.TOOLTIP_ATTRIBUTE_WIELDINFO = 17
m_TooltipFunction.TOOLTIP_ATTRIBUTE_COUNT = 18
m_TooltipFunction.TOOLTIP_ATTRIBUTE_RUNE_LEVEL = 19
m_TooltipFunction.TOOLTIP_ATTRIBUTE_RUNE_MAGIC_LEVEL = 20
m_TooltipFunction.TOOLTIP_ATTRIBUTE_RUNE_NAME = 21
m_TooltipFunction.TOOLTIP_ATTRIBUTE_CONTAINER_SIZE = 22
m_TooltipFunction.TOOLTIP_ATTRIBUTE_SPEED = 23
m_TooltipFunction.TOOLTIP_ATTRIBUTE_RARITY = 24
m_TooltipFunction.TOOLTIP_ATTRIBUTE_INCREMENTS = 25
m_TooltipFunction.TOOLTIP_ATTRIBUTE_CRITICALHIT_CHANCE = 26
m_TooltipFunction.TOOLTIP_ATTRIBUTE_CRITICALHIT_AMOUNT = 27
m_TooltipFunction.TOOLTIP_ATTRIBUTE_MANA_LEECH_CHANCE = 28
m_TooltipFunction.TOOLTIP_ATTRIBUTE_MANA_LEECH_AMOUNT = 29
m_TooltipFunction.TOOLTIP_ATTRIBUTE_LIFE_LEECH_CHANCE = 30
m_TooltipFunction.TOOLTIP_ATTRIBUTE_LIFE_LEECH_AMOUNT = 31
m_TooltipFunction.TOOLTIP_ATTRIBUTE_INCREMENT_COINS = 32
m_TooltipFunction.TOOLTIP_ATTRIBUTE_EXPERIENCE = 33
m_TooltipFunction.TOOLTIP_ATTRIBUTE_FIRE_ATTACK = 34
m_TooltipFunction.TOOLTIP_ATTRIBUTE_ENERGY_ATTACK = 35
m_TooltipFunction.TOOLTIP_ATTRIBUTE_ICE_ATTACK = 36
m_TooltipFunction.TOOLTIP_ATTRIBUTE_DEATH_ATTACK = 37
m_TooltipFunction.TOOLTIP_ATTRIBUTE_EARTH_ATTACK = 38
m_TooltipFunction.TOOLTIP_ATTRIBUTE_HOLY_ATTACK = 39
m_TooltipFunction.TOOLTIP_ATTRIBUTE_WATER_ATTACK = 40
m_TooltipFunction.TOOLTIP_ATTRIBUTE_ARCANE_ATTACK = 41
m_TooltipFunction.TOOLTIP_ATTRIBUTE_EXTRADEFENSE = 42
m_TooltipFunction.TOOLTIP_ATTRIBUTE_CORRUPTED = 47
m_TooltipFunction.TOOLTIP_ATTRIBUTE_VOID_CORRUPTED = 48
m_TooltipFunction.TOOLTIP_ATTRIBUTE_ANCIENT_CORRUPTED = 49
m_TooltipFunction.TOOLTIP_ATTRIBUTE_INFERNAL_CORRUPTED = 50
m_TooltipFunction.TOOLTIP_ATTRIBUTE_FRACTURED = 51
m_TooltipFunction.TOOLTIP_ATTRIBUTE_GEMS = 52
m_TooltipFunction.TOOLTIP_ATTRIBUTE_COMPARE_ITEMID = 53
m_TooltipFunction.TOOLTIP_ATTRIBUTE_GEM_LEVEL = 54
m_TooltipFunction.TOOLTIP_ATTRIBUTE_FORGE_TIER = 55

m_TooltipFunction.descriptionByAttributeId = {
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_ATTACK] = {name = "Attack: %s", icon = 4},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_DEFENSE] = {name = "Defense: %s", icon = 6},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_EXTRADEFENSE] = {name = "Extra Def: %s", icon = 6},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_WEIGHT] = {name = "%s", icon = 8},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_ARMOR] = {name = "Armor: %s", icon = 5},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_HITCHANCE] = {name = "Hit Chance: %s", icon = 47, symbol = true},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_SHOOTRANGE] = {name = "Range: %s", icon = 9},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_DURATION] = {name = "%s", icon = 38},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_CHARGES] = {name = "Charges: %s", icon = 10},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_FLUIDTYPE] = {name = "%s", icon = 27},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_ATTACK_SPEED] = {name = "Attack Speed: %s ms", icon = 20},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_KEY] = {name = "Key: %s", icon = 28},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_TEXT] = {name = "%s", icon = 17},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_WIELDINFO] = {name = "%s", icon = 17},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_RUNE_LEVEL] = {name = "Rune Level: %s", icon = 77},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_RUNE_MAGIC_LEVEL] = {name = "Rune Magic Level: %s", icon = 78},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_RUNE_NAME] = {name = "Rune Spell Name: %s", icon = 58},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_CONTAINER_SIZE] = {name = "Vol: %s", icon = 15},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_SPEED] = {name = "Speed: %s", icon = 51, symbol = true},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_CRITICALHIT_CHANCE] = {name = "Critical Hit Chance: %s%%", icon = 12, symbol = true},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_CRITICALHIT_AMOUNT] = {name = "Critical Hit Multiplier: %s%%", icon = 12, symbol = true},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_MANA_LEECH_CHANCE] = {name = "Mana Leech Chance: %s%%", icon = 45, symbol = true},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_MANA_LEECH_AMOUNT] = {name = "Mana Leech Multiplier: %s%%", icon = 45, symbol = true},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_LIFE_LEECH_CHANCE] = {name = "Life Leech Chance: %s%%", icon = 13, symbol = true},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_LIFE_LEECH_AMOUNT] = {name = "Life Leech Multiplier: %s%%", icon = 13, symbol = true},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_INCREMENT_COINS] = {name = "%s%% Extra Gold From Monsters", icon = 15, symbol = true},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_EXPERIENCE] = {name = "%s%% Extra Experience", icon = 49, symbol = true},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_FIRE_ATTACK] = {name = "Element Fire: %s%%", icon = 75, symbol = true},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_ENERGY_ATTACK] = {name = "Element Energy: %s%%", icon = 66, symbol = true},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_ICE_ATTACK] = {name = "Element Ice: %s%%", icon = 64, symbol = true},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_DEATH_ATTACK] = {name = "Element Death: %s%%", icon = 35, symbol = true},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_EARTH_ATTACK] = {name = "Element Earth: %s%%", icon = 91, symbol = true},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_HOLY_ATTACK] = {name = "Element Holy: %s%%", icon = 68, symbol = true},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_WATER_ATTACK] = {name = "Element Water: %s%%", icon = 76, symbol = true},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_ARCANE_ATTACK] = {name = "Element Arcane: %s%%", icon = 86, symbol = true},

	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_RARITY] = {
	[1] = {name = "Common", icon = 93, color = "#AAAAAA"}, -- Common (Gray)
	[2] = {name = "Uncommon", icon = 94, color = "#1EFF00"}, -- Uncommon (Green)
	[3] = {name = "Rare", icon = 25, color = "#0088FF"}, -- Rare (Blue)
	[4] = {name = "Epic", icon = 26, color = "#870DFF"}, -- Epic (Purple)
	[5] = {name = "Legendary", icon = 58, color = "#F5891D"}, -- Legendary (Orange)
	[6] = {name = "Exotic", icon = 96, color = "#FA5025"}, -- Exotic (Vivid Orange)
	[7] = {name = "Mythic", icon = 16, color = "#F0E229"}, -- Mythic (Golden Yellow)
	[8] = {name = "Chaos", icon = 52, color = "#990000"}, -- Chaos (Dark Red)
	[9] = {name = "Eternal", icon = 95, color = "#00CFFF"}, -- Eternal (Cyan)
	[10] = {name = "Divine", icon = 97, color = "#FFD700"}, -- Divine (Bright Gold)
	[11] = {name = "Phantasmal", icon = 99, color = "#A600FF"}, -- Phantasmal (Deep Purple)
	[12] = {name = "Celestial", icon = 98, color = "#7DFFFA"}, -- Celestial (Light Aqua)
	[13] = {name = "Cosmic", icon = 103, color = "#FF4500"}, -- Cosmic (Fiery Red-Orange)
	[14] = {name = "Abyssal", icon = 102, color = "#2b68b3"}, -- Abyssal (Blue Indigo)
	[15] = {name = "Transcendent", icon = 101, color = "#FF0000"}, -- Transcendent (Brutal Demonic Red)
	},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_RESISTANCES] = {
		[0] = {name = "Physical Absorb: %s%%", icon = 30}, -- COMBAT_PHYSICALDAMAGE
		[1] = {name = "Energy Absorb: %s%%", icon = 31}, -- COMBAT_ENERGYDAMAGE
		[2] = {name = "Earth Absorb: %s%%", icon = 34}, -- COMBAT_EARTHDAMAGE
		[3] = {name = "Fire Absorb: %s%%", icon = 32}, -- COMBAT_FIREDAMAGE
	--	[4] = {name = "Undefined Absorb: %s%%", icon = 0}, -- COMBAT_UNDEFINEDDAMAGE
		[5] = {name = "Lifedrain Absorb: %s%%", icon = 37}, -- COMBAT_LIFEDRAIN
		[6] = {name = "Manadrain Absorb: %s%%", icon = 40}, -- COMBAT_MANADRAIN
	--  [7] = {name = "Healing Absorb: %s%%", icon = 0}, -- COMBAT_HEALING
		[8] = {name = "Drown Absorb: %s%%", icon = 61}, -- COMBAT_DROWNDAMAGE
		[9] = {name = "Ice Absorb: %s%%", icon = 33}, -- COMBAT_ICEDAMAGE
		[10] = {name = "Holy Absorb: %s%%", icon = 36}, -- COMBAT_HOLYDAMAGE
		[11] = {name = "Death Absorb: %s%%", icon = 35}, -- COMBAT_DEATHDAMAGE
		[12] = {name = "Water Absorb: %s%%", icon = 40}, -- COMBAT_WATERDAMAGE
		[13] = {name = "Arcane Absorb: %s%%", icon = 56}, -- COMBAT_ARCANEDAMAGE
	};
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_INCREMENTS] = {
		[0] = {name = "Increase Physical Damage: %s%%", icon = 30}, -- COMBAT_PHYSICALDAMAGE
		[1] = {name = "Increase Energy Damage: %s%%", icon = 31}, -- COMBAT_ENERGYDAMAGE
		[2] = {name = "Increase Earth Damage: %s%%", icon = 34}, -- COMBAT_EARTHDAMAGE
		[3] = {name = "Increase Fire Damage: %s%%", icon = 32}, -- COMBAT_FIREDAMAGE
		[5] = {name = "Increase Lifedrain Damage: %s%%", icon = 37}, -- COMBAT_LIFEDRAIN
		[6] = {name = "Increase Manadrain Damage: %s%%", icon = 40}, -- COMBAT_MANADRAIN
		[7] = {name = "Increase Healing: %s%%", icon = 27} -- COMBAT_HEALING
	},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_STATS] = {
		[0] = {name = "Maximum Health: %s", icon = 39}, -- STAT_MAXHITPOINTS
		[1] = {name = "Maximum Mana: %s", icon = 40}, -- STAT_MAXMANAPOINTS
		[3] = {name = "Magic Level: %s", icon = 62} -- STAT_MAGICPOINTS
	},
	[m_TooltipFunction.TOOLTIP_ATTRIBUTE_SKILL] = {
		[0] = {name = "Fist Fighting: %s", icon = 60}, -- SKILL_FIST
		[1] = {name = "Club Fighting: %s", icon = 30}, -- SKILL_CLUB
		[2] = {name = "Sword Fighting: %s", icon = 18}, -- SKILL_SWORD
		[3] = {name = "Axe Fighting: %s", icon = 19}, -- SKILL_AXE
		[4] = {name = "Distance Fighting: %s", icon = 22}, -- SKILL_DISTANCE
		[5] = {name = "Shielding: %s", icon = 6}, -- SKILL_SHIELD
		[6] = {name = "Fishing: %s", icon = 23}, -- SKILL_FISHING
		[7] = {name = "Crafting: %s", icon = 90, color = "#8c0325"}, -- SKILL_CRAFTING
		[8] = {name = "Woodcutting: %s", icon = 89, color = "#b04900"}, -- SKILL_WOODCUTTING
		[9] = {name = "Mining: %s", icon = 82, color = "#997979"}, -- SKILL_MINING
		[10] = {name = "Herbalist: %s", icon = 81, color = "#00b04f"}, -- SKILL_HERBALIST
		[11] = {name = "Armorsmith: %s", icon = 5, color = "#ff7f39"}, -- SKILL_ARMORSMITH
		[12] = {name = "Weaponsmith: %s", icon = 4, color = "#ff4117"}, -- SKILL_WEAPONSMITH 
		[13] = {name = "Jewelsmith: %s", icon = 10, color = "#17c0ff"}, -- SKILL_JEWELSMITH
	},
}

m_TooltipFunction.config = {
	maxIconsInLine = 8,
	iconSize = 19,
}

function onLoad()
	connect(g_game, {
		onGameStart = onGameStart,
		onGameEnd = onGameEnd
	})
end

function onUnLoad()
	m_TooltipFunction.unbindCompareKeys()
	disconnect(g_game, {
		onGameStart = onGameStart,
		onGameEnd = onGameEnd
	})

	m_TooltipFunction.destroy()
end

function onGameStart()
	m_TooltipFunction.registerProtocol()
	m_TooltipFunction.bindCompareKeys()
	m_TooltipFunction.destroy()
end

function onGameEnd()
	m_TooltipFunction.unbindCompareKeys()
	m_TooltipFunction.unregisterProtocol()
	m_TooltipFunction.destroy()
end

m_TooltipFunction.registerProtocol = function()
	m_TooltipFunction.protocol = g_game.getProtocolGame()
	ProtocolGame.registerOpcode(m_TooltipFunction.GameServerParseTooltip, m_TooltipFunction.parseTooltip)
end

m_TooltipFunction.unregisterProtocol = function()
	m_TooltipFunction.protocol = nil
	ProtocolGame.unregisterOpcode(m_TooltipFunction.GameServerParseTooltip, m_TooltipFunction.parseTooltip)
end

function placeTooltipAtCursor(win, cursorPos, margin)
  margin = margin or 16
  local root = modules.game_interface.getRootPanel()
  local ww, wh = win:getWidth(), win:getHeight()
  local rw, rh = root:getWidth(), root:getHeight()

  local x = cursorPos.x + margin
  local y = cursorPos.y + margin

  if x + ww > rw then x = cursorPos.x - ww - margin end
  if x < margin then x = margin end
  if x + ww > rw - margin then x = rw - ww - margin end
  if y + wh > rh then y = cursorPos.y - wh - margin end
  if y < margin then y = margin end
  if y + wh > rh - margin then y = rh - wh - margin end

  win:setPosition({ x = x, y = y })
end

local function placeTooltipBeside(win, anchor, margin)
  if not win or not anchor then
    return
  end

  margin = margin or 12
  local root = g_ui.getRootWidget and g_ui.getRootWidget() or modules.game_interface.getRootPanel()
  local anchorPos = anchor:getPosition()
  local x = anchorPos.x + anchor:getWidth() + margin
  local y = anchorPos.y

  if root and x + win:getWidth() > root:getWidth() then
    x = math.max(0, anchorPos.x - win:getWidth() - margin)
  end

  if root and y + win:getHeight() > root:getHeight() then
    y = math.max(0, root:getHeight() - win:getHeight() - margin)
  end

  win:setPosition({ x = math.max(0, x), y = math.max(0, y) })
end

local function destroyTooltipWindow(windowField, listField)
  local window = m_TooltipList[windowField]
  local list = m_TooltipList[listField]
  if not window then
    return
  end
  local destroyField = windowField .. "Destroying"
  if m_TooltipList[destroyField] == window then
    return
  end
  m_TooltipList[destroyField] = window

  g_effects.fadeOut(window, 90)
  scheduleEvent(function()
    if list then
      list:destroyChildren()
    end
    if window and m_TooltipList[destroyField] == window then
      window:destroy()
    end
    if m_TooltipList[windowField] == window then
      m_TooltipList[windowField] = nil
      m_TooltipList[listField] = nil
    end
    if m_TooltipList[destroyField] == window then
      m_TooltipList[destroyField] = nil
    end
  end, 100)
end

m_TooltipFunction.parseTooltip = function(protocol, msg)
  local size = msg:getU8()
  local list = {}
  local compareList = {}
  local compareItemId = nil
  local readingCompare = false
  for i = 1, size do
    local attributeId = msg:getU8()
    local attributeValue
    local attributeType
    if msg:getU8() == 1 then
      attributeValue = (msg:getU8() == 1) and -msg:getU32() or msg:getU32()
      attributeType  = msg:getU32()
    else
      attributeValue = msg:getString()
    end

    if attributeId == m_TooltipFunction.TOOLTIP_ATTRIBUTE_COMPARE_ITEMID then
      compareItemId = tonumber(attributeValue)
      readingCompare = true
    elseif readingCompare then
      table.insert(compareList, { id = attributeId, value = attributeValue, type = attributeType })
    else
      table.insert(list, { id = attributeId, value = attributeValue, type = attributeType })
    end
  end

  local pending = m_TooltipList and m_TooltipList._pending
  if pending then
    m_TooltipList.itemId   = pending.itemId
    m_TooltipList.position = pending.pos
    m_TooltipList._pending = nil
  end

  if (not m_TooltipList.itemId) and m_TooltipList._owner and m_TooltipList._owner._ttItem then
    local it = m_TooltipList._owner._ttItem
    if it then m_TooltipList.itemId = it:getId() end
  end

  if m_TooltipList._ownerTag == 'trade' and m_TooltipList._owner then
    if m_TooltipList._owner.isHovered and not m_TooltipList._owner:isHovered() then
      m_TooltipList._owner = nil
      m_TooltipList._ownerTag = nil
      return
    end
  end

  if m_TooltipList._ownerTag == 'trade' and m_TooltipList._owner then
    if m_TooltipList._reqOwner ~= m_TooltipList._owner then
      return
    end
    if m_TooltipList._owner._ttSeq and m_TooltipList._reqSeq
       and m_TooltipList._owner._ttSeq ~= m_TooltipList._reqSeq then
      return
    end
  end

  if m_TooltipList._ownerTag == 'marketDetails' then
    m_TooltipList._ownerTag = nil
    if m_TooltipFunction.marketDetailsCallback then
      m_TooltipFunction.marketDetailsCallback(list)
    end
    return
  end
  m_TooltipFunction.open(list)

  if compareItemId and compareItemId > 0 and #compareList > 0 then
    m_TooltipFunction.open(compareList, {
      compare = true,
      itemId = compareItemId,
      position = m_TooltipList.position,
      anchorWindow = m_TooltipList.window
    })
  elseif m_TooltipList.compareWindow then
    destroyTooltipWindow("compareWindow", "compareList")
  end
end

m_TooltipFunction.cancelEvent = function()
  if m_TooltipFunction.event then
    m_TooltipFunction.event:cancel()
    m_TooltipFunction.event = nil
  end
end

m_TooltipFunction.cancelDestroyEvent = function()
  if m_TooltipFunction.destroyEvent then
    removeEvent(m_TooltipFunction.destroyEvent)
    m_TooltipFunction.destroyEvent = nil
  end
end

m_TooltipFunction.shouldCompareEquipped = function()
  return g_keyboard and g_keyboard.isShiftPressed and g_keyboard.isShiftPressed()
end

m_TooltipFunction.refreshCurrent = function()
	if not m_TooltipFunction.lastRefresh then
		return
	end

	if m_TooltipFunction.refreshEvent then
		removeEvent(m_TooltipFunction.refreshEvent)
	end

	m_TooltipFunction.refreshEvent = scheduleEvent(function()
		m_TooltipFunction.refreshEvent = nil
		if m_TooltipFunction.lastRefresh then
			m_TooltipFunction.lastRefresh()
		end
	end, 30)
end

m_TooltipFunction.startCompareWatcher = function()
	m_TooltipFunction.lastCompareState = m_TooltipFunction.shouldCompareEquipped()
	if m_TooltipFunction.compareWatchEvent then
		return
	end

	local function watch()
		m_TooltipFunction.compareWatchEvent = nil
		if not m_TooltipFunction.lastRefresh then
			return
		end

		local compareState = m_TooltipFunction.shouldCompareEquipped()
		if compareState ~= m_TooltipFunction.lastCompareState then
			m_TooltipFunction.lastCompareState = compareState
			m_TooltipFunction.refreshCurrent()
		end

		m_TooltipFunction.compareWatchEvent = scheduleEvent(watch, 80)
	end

	m_TooltipFunction.compareWatchEvent = scheduleEvent(watch, 80)
end

m_TooltipFunction.bindCompareKeys = function()
	if m_TooltipFunction.compareKeysBound or not g_keyboard then
		return
	end

	local root = modules.game_interface and modules.game_interface.getRootPanel and modules.game_interface.getRootPanel() or nil
	m_TooltipFunction.compareKeyboardRoot = root
	g_keyboard.bindKeyDown('Shift', m_TooltipFunction.refreshCurrent, root)
	g_keyboard.bindKeyUp('Shift', m_TooltipFunction.refreshCurrent, root)
	m_TooltipFunction.compareKeysBound = true
end

m_TooltipFunction.unbindCompareKeys = function()
	if not m_TooltipFunction.compareKeysBound or not g_keyboard then
		return
	end

	local root = m_TooltipFunction.compareKeyboardRoot
	g_keyboard.unbindKeyDown('Shift', m_TooltipFunction.refreshCurrent, root)
	g_keyboard.unbindKeyUp('Shift', m_TooltipFunction.refreshCurrent, root)
	m_TooltipFunction.compareKeyboardRoot = nil
	m_TooltipFunction.compareKeysBound = nil
end

m_TooltipFunction.create = function(position, item, virtual)
	if not item then
		return
	end

	m_TooltipFunction.lastRefresh = function()
		m_TooltipFunction.create(position, item, virtual)
	end
	m_TooltipFunction.startCompareWatcher()

	if m_TooltipList._owner and m_TooltipList._ownerTag == 'trade' then
		if m_TooltipList._owner.isHovered and m_TooltipList._owner:isHovered() then
		return
		else
		m_TooltipList._owner = nil
		m_TooltipList._ownerTag = nil
		end
  	end
	m_TooltipFunction.cancelEvent()
	m_TooltipList.itemId = item:getId()
	m_TooltipList.position = position
	if virtual then
		m_TooltipFunction.event = scheduleEvent(function()
			local msg = OutputMessage.create()
			msg:addU8(m_TooltipFunction.GameServerSendTooltip)
			msg:addU8(0)
			msg:addU16(item:getId())
			msg:addU16(item:getCount())
			msg:addU8(m_TooltipFunction.shouldCompareEquipped() and 1 or 0)
			m_TooltipFunction.protocol:send(msg)
		end, 200)
	else
        m_TooltipFunction.event = scheduleEvent(function()
            local msg = OutputMessage.create()
            msg:addU8(m_TooltipFunction.GameServerSendTooltip)
            msg:addU8(1)
            local itemPosition = item:getPosition()
            if itemPosition then
                m_TooltipFunction.protocol:addPosition(msg, itemPosition)
            else
                return
            end
            msg:addU16(item:getId())
            msg:addU8(item:getStackPos())
            msg:addU8(m_TooltipFunction.shouldCompareEquipped() and 1 or 0)
            m_TooltipFunction.protocol:send(msg)
        end, 200)
    end
end

m_TooltipFunction.createMarketOffer = function(position, item, offer)
  if not item or not offer then
    return
  end

  m_TooltipFunction.lastRefresh = function()
    m_TooltipFunction.createMarketOffer(position, item, offer)
  end
  m_TooltipFunction.startCompareWatcher()

  m_TooltipFunction.cancelEvent()
  m_TooltipList.itemId = item:getId()
  m_TooltipList.position = (g_window.getMousePosition and g_window.getMousePosition()) or position

  m_TooltipFunction.event = scheduleEvent(function()
    local msg = OutputMessage.create()
    msg:addU8(m_TooltipFunction.GameServerSendTooltip)
    msg:addU8(3)
    msg:addU32(offer:getTimeStamp())
    msg:addU16(offer:getCounter())
    msg:addU16(item:getId())
    msg:addU8(m_TooltipFunction.shouldCompareEquipped() and 1 or 0)
    m_TooltipFunction.protocol:send(msg)
  end, 200)
end

m_TooltipFunction.requestMarketOfferDetails = function(item, offer)
  if not item or not offer then
    return
  end

  m_TooltipFunction.cancelEvent()
  m_TooltipList._ownerTag = 'marketDetails'
  m_TooltipList.itemId = item:getId()

  m_TooltipFunction.event = scheduleEvent(function()
    local msg = OutputMessage.create()
    msg:addU8(m_TooltipFunction.GameServerSendTooltip)
    msg:addU8(3)
    msg:addU32(offer:getTimeStamp())
    msg:addU16(offer:getCounter())
    msg:addU16(item:getId())
    msg:addU8(0)
    m_TooltipFunction.protocol:send(msg)
  end, 100)
end

m_TooltipFunction.requestMarketDepotDetails = function(item, attributesKey)
  if not item then
    return
  end

  m_TooltipFunction.cancelEvent()
  m_TooltipList._ownerTag = 'marketDetails'
  m_TooltipList.itemId = item:getId()

  m_TooltipFunction.event = scheduleEvent(function()
    local msg = OutputMessage.create()
    msg:addU8(m_TooltipFunction.GameServerSendTooltip)
    msg:addU8(4)
    msg:addU16(item:getId())
    msg:addString(attributesKey or '')
    msg:addU8(0)
    m_TooltipFunction.protocol:send(msg)
  end, 100)
end

m_TooltipFunction.createMarketDepot = function(position, item, attributesKey)
  if not item then
    return
  end

  m_TooltipFunction.lastRefresh = function()
    m_TooltipFunction.createMarketDepot(position, item, attributesKey)
  end
  m_TooltipFunction.startCompareWatcher()

  m_TooltipFunction.cancelEvent()
  m_TooltipList.itemId = item:getId()
  m_TooltipList.position = (g_window.getMousePosition and g_window.getMousePosition()) or position

  m_TooltipFunction.event = scheduleEvent(function()
    local msg = OutputMessage.create()
    msg:addU8(m_TooltipFunction.GameServerSendTooltip)
    msg:addU8(4)
    msg:addU16(item:getId())
    msg:addString(attributesKey or '')
    msg:addU8(m_TooltipFunction.shouldCompareEquipped() and 1 or 0)
    m_TooltipFunction.protocol:send(msg)
  end, 200)
end

m_TooltipFunction.createGuildStorage = function(position, item, attributesKey, count)
  if not item then
    return
  end

  m_TooltipFunction.lastRefresh = function()
    m_TooltipFunction.createGuildStorage(position, item, attributesKey, count)
  end
  m_TooltipFunction.startCompareWatcher()

  m_TooltipFunction.cancelEvent()
  m_TooltipList.itemId = item:getId()
  m_TooltipList.position = (g_window.getMousePosition and g_window.getMousePosition()) or position

  m_TooltipFunction.event = scheduleEvent(function()
    local msg = OutputMessage.create()
    msg:addU8(m_TooltipFunction.GameServerSendTooltip)
    msg:addU8(5)
    msg:addU16(item:getId())
    msg:addU16(count or item:getCount() or 1)
    msg:addString(attributesKey or '')
    msg:addU8(m_TooltipFunction.shouldCompareEquipped() and 1 or 0)
    m_TooltipFunction.protocol:send(msg)
  end, 200)
end

m_TooltipFunction.destroyByItem = function(itemId)
	if itemId and m_TooltipList.itemId == itemId then
		m_TooltipFunction.destroy()
	end
end

m_TooltipFunction.destroy = function()
  m_TooltipFunction.cancelEvent()
  m_TooltipFunction.cancelDestroyEvent()
  m_TooltipFunction.lastRefresh = nil
  if m_TooltipFunction.refreshEvent then
    removeEvent(m_TooltipFunction.refreshEvent)
    m_TooltipFunction.refreshEvent = nil
  end
  if m_TooltipFunction.compareWatchEvent then
    removeEvent(m_TooltipFunction.compareWatchEvent)
    m_TooltipFunction.compareWatchEvent = nil
  end
  m_TooltipFunction.lastCompareState = nil
  destroyTooltipWindow("compareWindow", "compareList")
  if m_TooltipList.window then
    local window = m_TooltipList.window
    local list = m_TooltipList.list
    g_effects.fadeOut(window, 90)
    m_TooltipFunction.destroyEvent = scheduleEvent(function()
      if list then
        list:destroyChildren()
      end
      if window then
        window:destroy()
      end
      m_TooltipList.window = nil
      m_TooltipList.list = nil
      m_TooltipList._faded = nil
      m_TooltipFunction.destroyEvent = nil
    end, 100)
  end
end

m_TooltipFunction.addLabel = function(name, height, width, description, icon, color, update)
	local widget = g_ui.createWidget(name)
	widget:setId(description)
	if update then
		widget:setParent(m_TooltipFunction.list)
	end

	if description then
		widget:setText(description)
		width = math.max(widget:getWidth() + 64, width)
	end

	if color then
		widget:setColor(color)
	end

	if name == "TooltipSeparator" then
		local theme = m_TooltipFunction.activeTheme or m_TooltipFunction.tooltipThemes.default
		if theme and theme.separatorColor then
			widget:setBackgroundColor(theme.separatorColor)
		end
	end

	if icon then
		m_TooltipFunction.setIconImageType(widget:getChildById("icon"), icon)
	end

	if not update then
		widget:setParent(m_TooltipList.list)
	end

	return height + widget:getHeight() + 4, width, widget
end

m_TooltipFunction.getImageClip = function(id)
	if not id then
		return "0 0 " .. m_TooltipFunction.config.iconSize .. " " .. m_TooltipFunction.config.iconSize
	end

	return (((id - 1) % m_TooltipFunction.config.maxIconsInLine) * m_TooltipFunction.config.iconSize) .. " " .. ((math.ceil(id / m_TooltipFunction.config.maxIconsInLine) - 1)*m_TooltipFunction.config.iconSize) .. " " .. m_TooltipFunction.config.iconSize .. " " .. m_TooltipFunction.config.iconSize
end

m_TooltipFunction.setIconImageType = function(widget, id)
	if not id then
		return false
	end

	widget:setImageClip(m_TooltipFunction.getImageClip(id))
end

m_TooltipFunction.getAttribute = function(list, id)
	for _, attributeValues in pairs(list) do
		if attributeValues.id == id then
			return attributeValues.value
		end
	end

	return ""
end

m_TooltipFunction.tooltipBaseTheme = {
	backgroundColor = "#120f0be6",
	borderWidth = 1,
	itemMarginTop = 7,
	listMarginTop = 0,
	listMarginLeft = 6,
	listMarginRight = 6,
	listMarginBottom = 6
}

m_TooltipFunction.rarityThemeColors = {
	["Common"] = "#AAAAAA",
	["Uncommon"] = "#1EFF00",
	["Rare"] = "#0088FF",
	["Epic"] = "#870DFF",
	["Legendary"] = "#F5891D",
	["Exotic"] = "#FA5025",
	["Mythic"] = "#F0E229",
	["Chaos"] = "#990000",
	["Eternal"] = "#00CFFF",
	["Divine"] = "#FFD700",
	["Phantasmal"] = "#A600FF",
	["Celestial"] = "#7DFFFA",
	["Cosmic"] = "#FF4500",
	["Abyssal"] = "#2b68b3",
	["Transcendent"] = "#FF0000"
}

local function brightenHexColor(hex, amount)
	if type(hex) ~= "string" or hex:sub(1, 1) ~= "#" then
		return "#ffffff"
	end

	local digits = hex:gsub("#", "")
	if #digits ~= 6 then
		return "#ffffff"
	end

	local function brighten(channel)
		local value = tonumber(channel, 16) or 0
		value = math.min(255, math.floor(value + (255 - value) * amount))
		return string.format("%02X", value)
	end

	return "#" .. brighten(digits:sub(1, 2)) .. brighten(digits:sub(3, 4)) .. brighten(digits:sub(5, 6))
end

m_TooltipFunction.getTooltipTheme = function(rarityName, rarityColor, corruptionColor)
	local borderColor = rarityColor or m_TooltipFunction.rarityThemeColors[rarityName] or "#b88a2f"
	local accentColor = corruptionColor or borderColor
	if accentColor:lower() == borderColor:lower() then
		accentColor = brightenHexColor(accentColor, 0.45)
	end

	return {
		backgroundColor = m_TooltipFunction.tooltipBaseTheme.backgroundColor,
		borderWidth = m_TooltipFunction.tooltipBaseTheme.borderWidth,
		borderColor = borderColor,
		borderColorTop = accentColor,
		borderColorBottom = accentColor,
		separatorColor = accentColor,
		itemMarginTop = m_TooltipFunction.tooltipBaseTheme.itemMarginTop,
		listMarginTop = m_TooltipFunction.tooltipBaseTheme.listMarginTop,
		listMarginLeft = m_TooltipFunction.tooltipBaseTheme.listMarginLeft,
		listMarginRight = m_TooltipFunction.tooltipBaseTheme.listMarginRight,
		listMarginBottom = m_TooltipFunction.tooltipBaseTheme.listMarginBottom
	}
end

m_TooltipFunction.applyTooltipTheme = function(theme)
	theme = theme or m_TooltipFunction.getTooltipTheme(nil, nil, nil)

	local window = m_TooltipList.window
	if not window then
		return
	end

	window:setBackgroundColor(theme.backgroundColor or "#120f0be6")
	window:setBorderWidth(theme.borderWidth or 0)
	window:setBorderColor(theme.borderColor or "#b88a2f")
	window:setBorderColorTop(theme.borderColorTop or theme.borderColor or "#b88a2f")
	window:setBorderColorBottom(theme.borderColorBottom or theme.borderColor or "#b88a2f")
	window:setBorderColorLeft(theme.borderColorLeft or theme.borderColor or "#b88a2f")
	window:setBorderColorRight(theme.borderColorRight or theme.borderColor or "#b88a2f")

	local frame = window:recursiveGetChildById("tooltipFrame")
	if frame then
		frame:setImageSource("")
		frame:setImageBorder(0)
		frame:setImageBorderLeft(0)
		frame:setImageBorderRight(0)
		frame:setImageBorderTop(0)
		frame:setImageBorderBottom(0)
		frame:setBackgroundColor("#00000000")
	end

	local itemWidget = window:recursiveGetChildById("item")
	if itemWidget then
		itemWidget:setMarginTop(theme.itemMarginTop or 7)
	end

	local listWidget = window:recursiveGetChildById("list")
	if listWidget then
		listWidget:setMarginTop(theme.listMarginTop or 0)
		listWidget:setMarginLeft(theme.listMarginLeft or 6)
		listWidget:setMarginRight(theme.listMarginRight or 6)
		listWidget:setMarginBottom(theme.listMarginBottom or 6)
	end

	for _, widgetId in ipairs({
		"tooltipOrnamentTop",
		"tooltipFrameTopLeft",
		"tooltipFrameTop",
		"tooltipFrameTopRight",
		"tooltipFrameLeft",
		"tooltipFrameRight",
		"tooltipFrameBottomLeft",
		"tooltipFrameBottom",
		"tooltipFrameBottomRight"
	}) do
		local widget = window:recursiveGetChildById(widgetId)
		if widget then
			widget:setImageSource("")
		end
	end

	m_TooltipFunction.activeTheme = theme
end

m_TooltipFunction.titleCase = function(str)
    local words = {}
    for word in str:gmatch("%S+") do
        table.insert(words, word)
    end

    for i, word in ipairs(words) do
        local firstLetter = word:sub(1, 1):upper()
        local restOfWord = word:sub(2)
        words[i] = firstLetter .. restOfWord
    end

    local result = table.concat(words, " ")
    return result
end

m_TooltipFunction.open = function(list, options)
	options = options or {}
	local windowField = options.compare and "compareWindow" or "window"
	local listField = options.compare and "compareList" or "list"
	local destroyField = windowField .. "Destroying"
	if m_TooltipList[destroyField] == m_TooltipList[windowField] then
		m_TooltipList[windowField] = nil
		m_TooltipList[listField] = nil
	end

	local savedWindow = m_TooltipList.window
	local savedList = m_TooltipList.list
	local savedItemId = m_TooltipList.itemId
	local savedPosition = m_TooltipList.position

	m_TooltipList.window = m_TooltipList[windowField]
	m_TooltipList.list = m_TooltipList[listField]
	if options.itemId then
		m_TooltipList.itemId = options.itemId
	end
	if options.position then
		m_TooltipList.position = options.position
	end

	if not m_TooltipList.position then
  local mp = (g_window.getMousePosition and g_window.getMousePosition()) or { x = 200, y = 200 }
  m_TooltipList.position = mp
end

	if not options.compare then
		m_TooltipFunction.cancelDestroyEvent()
	end
	
	local isNewWindow = not m_TooltipList.window
	if isNewWindow then
  m_TooltipList.window = g_ui.displayUI("game_tooltip")
  m_TooltipList.list = m_TooltipList.window:getChildById("list")
  m_TooltipList[windowField] = m_TooltipList.window
  m_TooltipList[listField] = m_TooltipList.list
else
  m_TooltipList.list:destroyChildren()
end
	 local root = g_ui.getRootWidget and g_ui.getRootWidget() or modules.game_interface.getRootPanel()
if root and m_TooltipList.window:getParent() ~= root then
  m_TooltipList.window:setParent(root)
end

m_TooltipList.window:show()
m_TooltipList.window:raise()
m_TooltipList.window:setFocusable(false)
if isNewWindow then
  m_TooltipList.window:setOpacity(0)
end
if m_TooltipList.window.setPhantom then
  m_TooltipList.window:setPhantom(true)
end

if isNewWindow then
  g_effects.fadeIn(m_TooltipList.window, 120)
else
  m_TooltipList.window:setOpacity(1)
end
m_TooltipList._faded = true

local itemWidget = m_TooltipList.window:recursiveGetChildById('item')
if itemWidget then
  if itemWidget.clear then
    itemWidget:clear()
  else
    itemWidget:setItemId(0)
    itemWidget:setItemCount(0)
  end
  itemWidget:setVirtual(true)

  local set = false
  local compareItemId = tonumber(m_TooltipFunction.getAttribute(list, m_TooltipFunction.TOOLTIP_ATTRIBUTE_COMPARE_ITEMID))

  if compareItemId and compareItemId > 0 then
    itemWidget:setItemId(compareItemId)
    set = true
  end

  if not set
     and not options.compare
     and m_TooltipList._ownerTag == 'trade'
     and m_TooltipList._owner
     and m_TooltipList._owner._ttItem
     and itemWidget.setItem then
    itemWidget:setItem(m_TooltipList._owner._ttItem)
    set = true
  end

  if not set and m_TooltipList.itemId then
    itemWidget:setItemId(m_TooltipList.itemId)
    set = true
  end
else
end

local height = 48
local width = 40
local baseName = m_TooltipFunction.titleCase(
    m_TooltipFunction.getAttribute(list, m_TooltipFunction.TOOLTIP_ATTRIBUTE_NAME)
)

local rarityName, rarityColor
for _, attr in pairs(list) do
    if attr.id == m_TooltipFunction.TOOLTIP_ATTRIBUTE_RARITY then
        local v = m_TooltipFunction.descriptionByAttributeId[attr.id][attr.value]
        rarityName  = v.name
        rarityColor = v.color
        break
    end
end

local stateTag = nil
local tagText = nil
local tagColor = nil
local iconId = nil

for _, attr in pairs(list) do
	if attr.id == m_TooltipFunction.TOOLTIP_ATTRIBUTE_FRACTURED then
		stateTag = "[Fractured]"
		break
    elseif attr.id == m_TooltipFunction.TOOLTIP_ATTRIBUTE_INFERNAL_CORRUPTED then
		stateTag = "[Infernal Corruption]"
	elseif attr.id == m_TooltipFunction.TOOLTIP_ATTRIBUTE_ANCIENT_CORRUPTED then
		stateTag = "[Ancient Corruption]"
	elseif attr.id == m_TooltipFunction.TOOLTIP_ATTRIBUTE_VOID_CORRUPTED then
		stateTag = "[Void Corruption]"
	elseif attr.id == m_TooltipFunction.TOOLTIP_ATTRIBUTE_CORRUPTED then
		stateTag = "[Corrupted]"
	end
end

if stateTag == "[Fractured]" then
	tagText = stateTag
	tagColor = "#1BFFF1"
	iconId = 105
elseif stateTag == "[Infernal Corruption]" then
	tagText = stateTag
	tagColor = "#FF1B1B"
	iconId = 108
elseif stateTag == "[Ancient Corruption]" then
    tagText = stateTag
    tagColor = "#FF9A00"
    iconId = 109
elseif stateTag == "[Void Corruption]" then
    tagText = stateTag
    tagColor = "#9A3AFF"
    iconId = 106
elseif stateTag == "[Corrupted]" then
    tagText = stateTag
    tagColor = "#E600FF"
    iconId = 107
end

m_TooltipFunction.applyTooltipTheme(m_TooltipFunction.getTooltipTheme(rarityName, rarityColor, tagColor))

local row = g_ui.createWidget("VoidTagRow", m_TooltipList.list)
row:setMarginLeft(18)

if iconId then
    local iconWidget = g_ui.createWidget("LookItemIconAttribute", row)
    iconWidget:getChildById("icon"):setImageClip(
        m_TooltipFunction.getImageClip(iconId)
    )
    iconWidget:getChildById("icon"):setColor(tagColor)
    iconWidget:setMarginRight(3)
end

if tagText then
    local tagLabel = g_ui.createWidget("LookItemName", row)
    tagLabel:setText(tagText .. " ")
    tagLabel:setColor(tagColor)
end

local nameLabel = g_ui.createWidget("LookItemName", row)
nameLabel:setText((rarityName and rarityName .. " " or "") .. baseName)
nameLabel:setColor(rarityColor)

height = height + row:getHeight() + 4
width = math.max(width, row:getWidth() + 16)
height = m_TooltipFunction.addLabel("TooltipSeparator", height, width)

local hasRarity = false
local hasAttributes = false	
local lastAttributeId
local hasStructuredRarityTooltip = rarityName ~= nil or stateTag ~= nil
for _, attributeValues in pairs(list) do
	-- if attributeValues.id == m_TooltipFunction.TOOLTIP_ATTRIBUTE_TEXT then
	--   else
	local v = m_TooltipFunction.descriptionByAttributeId[attributeValues.id]
	if v then
		local skipStandaloneDescription = attributeValues.id == m_TooltipFunction.TOOLTIP_ATTRIBUTE_TEXT and hasStructuredRarityTooltip
		if lastAttributeId == m_TooltipFunction.TOOLTIP_ATTRIBUTE_WEIGHT or lastAttributeId == m_TooltipFunction.TOOLTIP_ATTRIBUTE_RARITY then
			height = m_TooltipFunction.addLabel("TooltipSeparator", height, width)
			if attributeValues.id == m_TooltipFunction.TOOLTIP_ATTRIBUTE_RARITY then
			local titleText  = "Rarity"
			local titleColor = rarityColor

			if stateTag then
				titleText  = stateTag:gsub("[%[%]]", "")
				titleColor = tagColor
			end

			height, width, rarityLabel = m_TooltipFunction.addLabel(
				"LookItemSectionTitle", height, width, titleText
			)

			rarityLabel:setColor(titleColor)
			hasRarity = true
			else
				height, width = m_TooltipFunction.addLabel("LookItemSectionTitle", height, width, "Attributes")
				hasAttributes = true
			end
			local label = m_TooltipList.list:getLastChild()
			if label then
   				label:setTextAlign(AlignLeft)
				label:setMarginLeft(16)
			end
		end
		if skipStandaloneDescription then
			-- Keep TOOLTIP_ATTRIBUTE_TEXT available for the rarity block parser below,
			-- but do not render the same generated rarity summary as a top text row.
		elseif not v.name then
			v = v[attributeValues.type] or v[attributeValues.value]
			if v then
				if tonumber(attributeValues.value) and attributeValues.value > 0 then
					attributeValues.value = "+" .. attributeValues.value
				end
				local description = v.name:format(attributeValues.value)
				if attributeValues.id == m_TooltipFunction.TOOLTIP_ATTRIBUTE_RARITY then
					local container = g_ui.createWidget("RarityIcons")
					container:setParent(m_TooltipList.list)

					-- local rarityName = g_ui.createWidget("LookItemName", container)
					-- rarityName:setText(v.name)
					-- rarityName:setColor(v.color)
					-- rarityName:setTextAlign(AlignLeft)
					-- rarityName:setMarginLeft(16)
					-- rarityName:setMarginBottom(4)

					local starContainer = g_ui.createWidget("StarsContainer", container)
					starContainer:setMarginTop(4)

					local CorruptionIcons = {
						["Corrupted"]           = { icon = 110, color = "#E600FF" },
						["Void Corruption"]     = { icon = 111, color = "#9A3AFF" },
						["Ancient Corruption"]  = { icon = 112, color = "#FF9A00" },
						["Infernal Corruption"] = { icon = 113, color = "#FF1B1B" },
						["Fractured"]           = { icon = 114, color = "#1BFFF1" }
					}

					local iconCount = 1
					local rarityValue = tonumber(attributeValues.value) or 0

					if rarityValue >= 1 and rarityValue < 2 then
						iconCount = 1
					elseif rarityValue >= 2 and rarityValue < 4 then
						iconCount = 2
					elseif rarityValue >= 4 and rarityValue < 6 then
						iconCount = 3
					elseif rarityValue >= 6 and rarityValue < 10 then
						iconCount = 4
					elseif rarityValue >= 10 and rarityValue < 15 then
						iconCount = 5
					elseif rarityValue >= 15 then
						iconCount = 6
					end

					local finalIcon  = v.icon
					local finalColor = v.color

					if stateTag then
						local clean = stateTag:gsub("[%[%]]", "")
						local cfg = CorruptionIcons[clean]
						if cfg then
							finalIcon  = cfg.icon
							finalColor = cfg.color
						end
					end

					for i = 1, iconCount do
						local iconWidget = g_ui.createWidget("LookItemIconAttribute", starContainer)

						iconWidget:getChildById("icon"):setImageClip(
							m_TooltipFunction.getImageClip(finalIcon)
						)
						iconWidget:getChildById("icon"):setColor(finalColor)

						iconWidget:setMarginLeft(4)
						iconWidget:setMarginRight(4)
					end

					height = height + container:getHeight() + 4
					width = math.max(container:getWidth(), width)

					local customIconPriorityPatterns = {
						{ pattern = "execute chance", icon = 20 },
						{ pattern = "at or below", icon = 20 },
						{ pattern = "cripple chance", icon = 79 },
						{ pattern = "slow target", icon = 79 },
						{ pattern = "blast chance", icon = 70 },
						{ pattern = "on kill, explode", icon = 70 },
						{ pattern = "thorns chance", icon = 52 },
						{ pattern = "reflect %d+ physical damage", icon = 52 },
						{ pattern = "guard chance", icon = 6 },
						{ pattern = "reduce hit damage", icon = 6 },
						{ pattern = "second wind chance", icon = 39 },
						{ pattern = "restore %d+%% max health", icon = 39 },
						{ pattern = "cleanse chance", icon = 41 },
						{ pattern = "remove 1 random debuff", icon = 41 },
						{ pattern = "mana surge chance", icon = 40 },
						{ pattern = "restore %d+%% max mana", icon = 40 },
						{ pattern = "dodge chance", icon = 81 },
						{ pattern = "parry chance", icon = 3 },
						{ pattern = "reflect %d+%% of received damage", icon = 3 },
						{ pattern = "abyssal depths", icon = 102 },
						{ pattern = "increase damage done", icon = 4 },
						{ pattern = "spellfury", icon = 62 },
						{ pattern = "increase spell damage", icon = 62 },
						{ pattern = "ascendance", icon = 81 },
						{ pattern = "gain %+%d+%% dodge", icon = 81 },
						{ pattern = "arcane blasts", icon = 56 },
						{ pattern = "immobilize the target", icon = 79 },
						{ pattern = "chain lightning", icon = 31 },
						{ pattern = "energy burst", icon = 31 },
						{ pattern = "emberstorm", icon = 32 },
						{ pattern = "burn it", icon = 32 },
						{ pattern = "poison the attacker", icon = 34 },
						{ pattern = "poison deals", icon = 34 },
						{ pattern = "fear nearby enemies", icon = 49 },
						{ pattern = "restore %d+ health and %d+ mana every second", icon = 40 },
						{ pattern = "blood rage", icon = 4 },
						{ pattern = "increase speed by", icon = 51 },
						{ pattern = "battle boon", icon = 51 },
						{ pattern = "void mark", icon = 49 },
						{ pattern = "takes %d+%% more damage", icon = 4 },
						{ pattern = "gravity field", icon = 61 },
						{ pattern = "pulled inward", icon = 61 },
						{ pattern = "time slip", icon = 58 },
						{ pattern = "spell cooldowns recover", icon = 58 },
					}

					local customIconMapping = {
						Level = 104,
						Physical = 30,
						Energy   = 31,
						Earth    = 34,
						Fire     = 32,
						Drown    = 61,
						Ice      = 33,
						Holy     = 36,
						Death    = 35,
						Water    = 40,
						Arcane   = 56,
						attack = 4,
						defense = 6,
						["extra def"] = 6,
						armor = 5,
						["hit chance"] = 47,
						["attack speed"] = 20,
						speed = 51,
						["critical hit"] = 12,
						["critical chance"] = 12,
						["mana chance"] = 45,
						["mana amount"] = 45,
						["life chance"] = 13,
						["life amount"] = 13,
						Club = 30,
						Sword = 18,
						Axe = 19,
						Fist = 60,
						Distance = 22,
						Shielding = 25,
						Fishing = 23,
						Crafting = 90,
						Woodcutting = 89,
						Mining = 82,
						Herbalism = 81,
						Armorsmithing = 5,
						Weaponsmithing = 4,
						Jewelsmithing = 10,
						Magic = 62,
						["Element: Fire"]   = 75,
						["Element: Energy"] = 66,
						["Element: Ice"]    = 64,
						["Element: Death"]  = 35,
						["Element: Earth"]  = 91,
						["Element: Water"]  = 76,
						["Element: Arcane"] = 86,
						["Element: Holy"]   = 68,
					  }
					  local descriptionText = m_TooltipFunction.getAttribute(list, m_TooltipFunction.TOOLTIP_ATTRIBUTE_TEXT)
					  if descriptionText and descriptionText ~= "" then
						for line in descriptionText:gmatch("[^\r\n,]+") do
						  line = line:gsub("^%s*(.-)%s*$", "%1")
						  if line ~= "" then
							local iconFound = nil
							local lowerLine = line:lower()
							for _, entry in ipairs(customIconPriorityPatterns) do
							  if lowerLine:find(entry.pattern) then
								iconFound = entry.icon
								break
							  end
							end
							if not iconFound then
							  for keyword, iconId in pairs(customIconMapping) do
							    if lowerLine:find(keyword:lower()) then
								  iconFound = iconId
								  break
							    end
							  end
							end
							if not iconFound then
							  for keyword, iconId in pairs(customIconMapping) do
							    if line:find(keyword) then
								iconFound = iconId
								break
							    end
							  end
							end
							height, width = m_TooltipFunction.addLabel("LookItemIconAttribute", height, width, line, iconFound, nil)
						  end
						end
					  end
				else
					height, width = m_TooltipFunction.addLabel("LookItemIconAttribute", height, width, description, v.icon, v.color)
				end
				
			end		
		elseif attributeValues.value ~= "" then
			if tonumber(attributeValues.value) and attributeValues.value > 0 then
				if v.symbol then
					attributeValues.value = "+" .. attributeValues.value
				end
			elseif string.sub(attributeValues.value, 1, 1) == "\n" then
				attributeValues.value = string.sub(attributeValues.value, 2, #attributeValues.value)
			end
				height, width = m_TooltipFunction.addLabel("LookItemIconAttribute", height, width, v.name:format(attributeValues.value), v.icon, v.color)
		end
		lastAttributeId = attributeValues.id
end
-- end
end

local function renderGemTooltipStars(row, level, maxLevel)
		local starsRow = row and row:recursiveGetChildById("gemStars") or row
		if not starsRow then
			return
		end

		starsRow:destroyChildren()
		level = math.max(0, tonumber(level) or 0)
		maxLevel = math.max(0, tonumber(maxLevel) or 0)
		if maxLevel == 0 then
			return
		end

		starsRow:setWidth((maxLevel * 16) + math.max(0, maxLevel - 1) * 2)
		for index = 1, maxLevel do
			local star = g_ui.createWidget("GemTooltipStarIcon", starsRow)
			star:setImageSource(index <= level and "/images/sockets/star" or "/images/sockets/star_empty")
		end
end

local function getSocketGemCompactLine(gemName, gemTooltip)
	gemName = tostring(gemName or "")
	gemTooltip = tostring(gemTooltip or "")

	local health, mana = gemName:match("Health%s*%+([%d%.%,]+)%s+Mana%s*%+([%d%.%,]+)")
	if not health or not mana then
		health, mana = gemTooltip:match("Health%s*%+([%d%.%,]+)%s+Mana%s*%+([%d%.%,]+)")
	end
	if not health or not mana then
		health, mana = gemTooltip:match("Bonus:%s*%+([%d%.%,]+)%s*max%s*HP,%s*%+([%d%.%,]+)%s*max%s*Mana")
	end
	if health and mana then
		return string.format("Health +%s Mana +%s", health, mana)
	end

	local livingForm = gemTooltip:match("Living Form:%s*([^\n]+)")
	local livingDamage = gemTooltip:match("Power:%s*%+([%d%.%,]+)%% damage")
	if livingForm or livingDamage then
		return string.format("%s  Damage +%s%%", livingForm or "Dormant", livingDamage or "0")
	end

	local possessionSouls = gemTooltip:match("Souls:%s*([^\n]+)")
	if possessionSouls then
		return "Souls: " .. possessionSouls:gsub("^%s+", ""):gsub("%s+$", "")
	end

	possessionSouls = gemTooltip:match("Captured Souls:%s*([^%d/\n][^\n]*)")
	if possessionSouls then
		return "Souls: " .. possessionSouls:gsub("^%s+", ""):gsub("%s+$", "")
	end

	local capturedCurrent, capturedMax = gemTooltip:match("Captured Souls:%s*(%d+)%s*/%s*(%d+)")
	if capturedCurrent and capturedMax then
		if tonumber(capturedCurrent) and tonumber(capturedCurrent) > 0 then
			local names = {}
			for line in gemTooltip:gmatch("[^\n]+") do
				local soulName = line:match("^%s*([^%(]+)%s+T%d+%s*%(")
				if soulName then
					names[#names + 1] = soulName:gsub("%s+$", "")
				end
			end
			if #names > 0 then
				return "Souls: " .. table.concat(names, ", ")
			end
		end
		return string.format("Souls: %s/%s", capturedCurrent, capturedMax)
	end

	local obituaryName, obituaryDamage = gemTooltip:match("Obituary:%s*([^+\n]+)%s+%+([%d%.%,]+)%%")
	if obituaryName and obituaryDamage then
		return string.format("%s  Damage +%s%%", obituaryName:gsub("%s+$", ""), obituaryDamage)
	end

	obituaryName, obituaryDamage = gemTooltip:match("Active Obituaries:%s*\n%s*([^:\n]+):%s*%+([%d%.%,]+)%% damage")
	if obituaryName and obituaryDamage then
		return string.format("%s  Damage +%s%%", obituaryName:gsub("%s+$", ""), obituaryDamage)
	end

	if gemTooltip:match("Obituary:%s*No deaths recorded")
		or gemTooltip:match("Diary:%s*No active deaths recorded") then
		return "No killer recorded  Damage +0%"
	end

	local nemesisName, nemesisMinutes, nemesisDamage, nemesisReduction = gemTooltip:match("Nemesis:%s*([^%(%)\n]+)%s+(%d+)m%s*%(%+([%d%.%,]+)%% damage,%s*%-([%d%.%,]+)%% damage taken%)")
	if nemesisName and nemesisDamage and nemesisReduction then
		return string.format("Branded: %s %sm  Damage +%s%%  Taken -%s%%", nemesisName:gsub("%s+$", ""), nemesisMinutes or "?", nemesisDamage, nemesisReduction)
	end

	nemesisDamage, nemesisReduction = gemTooltip:match("Nemesis:%s*None%s*%(%+([%d%.%,]+)%% damage,%s*%-([%d%.%,]+)%% damage taken%)")
	if nemesisDamage and nemesisReduction then
		return string.format("No branded player  Damage +%s%%  Taken -%s%%", nemesisDamage, nemesisReduction)
	end

	local outfits = gemTooltip:match("Outfits:%s*([%d%.%,]+%%)")
	local mounts = gemTooltip:match("Mounts:%s*([%d%.%,]+%%)")
	if outfits or mounts then
		return string.format("Outfits: %s Mounts: %s", outfits or "0.0%", mounts or "0.0%")
	end

	local phoenixCharges, phoenixMaxCharges = gemTooltip:match("Revives:%s*(%d+)%/(%d+)")
	if phoenixCharges and phoenixMaxCharges then
		return string.format("Revives Remaining: %s/%s", phoenixCharges, phoenixMaxCharges)
	end

	local abattoirChain, abattoirHeat, abattoirTier = gemTooltip:match("Chain:%s*([%d%.%,]+)%s+Heat:%s*([%d%.%,]+)%%%s+T(%d+)")
	if abattoirChain and abattoirHeat then
		return string.format("Chain: %s  Heat: %s%%  T%s", abattoirChain, abattoirHeat, abattoirTier)
	end
	abattoirChain, abattoirHeat = gemTooltip:match("Chain:%s*([%d%.%,]+)%s+Heat:%s*([%d%.%,]+)%%")
	if abattoirChain and abattoirHeat then
		return string.format("Chain: %s  Heat: %s%%", abattoirChain, abattoirHeat)
	end
	abattoirChain, abattoirHeat = gemTooltip:match("Kill Chain:%s*([%d%.%,]+).-Slaughter Heat:%s*([%d%.%,]+)%%")
	if abattoirChain and abattoirHeat then
		local heatTier = gemTooltip:match("Heat Tier%s*(%d+):")
		if heatTier then
			return string.format("Chain: %s  Heat: %s%%  T%s", abattoirChain, abattoirHeat, heatTier)
		end
		return string.format("Chain: %s  Heat: %s%%", abattoirChain, abattoirHeat)
	end

	local hauntedProgress, hauntedRequired, hauntedPercent, hauntedLevel = gemTooltip:match("Haunted Hunt:%s*(%d+)%/(%d+)%s*%((%d+)%%%)%s*Haunted:%s*Yes%s*%((%d+)%)")
	if not hauntedProgress or not hauntedRequired then
		hauntedProgress, hauntedRequired, hauntedPercent = gemTooltip:match("Haunted Hunt:%s*(%d+)%/(%d+)%s*%((%d+)%%%)")
	end
	if hauntedProgress and hauntedRequired then
		local line = string.format("Progress: %s/%s (%s%%)", comma_value(hauntedProgress), comma_value(hauntedRequired), hauntedPercent or "0")
		if hauntedLevel then
			line = line .. string.format("  Haunted: %s", hauntedLevel)
		end
		return line
	end

	local cartographyDiscovered, cartographyTotal, cartographyPercent = gemTooltip:match("Zones:%s*(%d+)%/(%d+)%s*%(([%d%.%,]+)%%%)")
	if not cartographyDiscovered or not cartographyTotal then
		cartographyDiscovered, cartographyTotal = gemTooltip:match("Zones:%s*(%d+)%/(%d+)")
		cartographyPercent = gemTooltip:match("World Exploration:%s*([%d%.%,]+)%%")
	end
	if cartographyDiscovered and cartographyTotal then
		return string.format("Zones: %s/%s (%s%%)", comma_value(cartographyDiscovered), comma_value(cartographyTotal), cartographyPercent or "0")
	end

	local tideMode, tideKind, tidePercent = gemTooltip:match("Tide:%s*(Peak|Offpeak)%s+([Rr]arity|EXP)%s*%+([%d%.%,]+)%%")
	if tideMode and tideKind and tidePercent then
		local label = tideKind:lower() == "rarity" and "Rarity Loot" or "EXP"
		return string.format("%s  %s +%s%%", tideMode, label, tidePercent)
	end

	local waystoneCount, waystoneMax, waystoneReduction = gemTooltip:match("Waystone Conquest:%s*(%d+)%/(%d+)%s+Cooldown:%s*%-([%d%.%,]+)%%")
	if waystoneCount and waystoneMax and waystoneReduction then
		return string.format("Waystone: %s/%s  Cooldown -%s%%", waystoneCount, waystoneMax, waystoneReduction)
	end
	waystoneCount, waystoneMax = gemTooltip:match("Waystone Conquest:%s*(%d+)%/(%d+)")
	waystoneReduction = gemTooltip:match("Boss Cooldown Reduction:%s*([%d%.%,]+)%%")
	if waystoneCount and waystoneMax and waystoneReduction then
		return string.format("Waystone: %s/%s  Cooldown -%s%%", waystoneCount, waystoneMax, waystoneReduction)
	end

	local overkillStored, overkillMax = gemTooltip:match("Overkill:%s*([%d%.%,]+)%/(%d[%d%.%,]*)%s*stored")
	if not overkillStored or not overkillMax then
		overkillStored, overkillMax = gemTooltip:match("Stored Damage:%s*([%d%.%,]+)%/(%d[%d%.%,]*)")
	end
	if overkillStored and overkillMax then
		return string.format("Stored Damage: %s/%s", overkillStored, overkillMax)
	end

	local requiemSouls, requiemRequired = gemTooltip:match("Requiem:%s*([%d%.%,]+)%/(%d[%d%.%,]*)%s*souls")
	if not requiemSouls or not requiemRequired then
		requiemSouls, requiemRequired = gemTooltip:match("Souls:%s*([%d%.%,]+)%/(%d[%d%.%,]*)")
	end
	if requiemSouls and requiemRequired then
		return string.format("Souls: %s/%s", requiemSouls, requiemRequired)
	end

	local momentumCharge, momentumMax, momentumArmed = gemTooltip:match("Momentum:%s*([%d%.%,]+)%/(%d[%d%.%,]*)%s*(%a*)")
	if momentumCharge and momentumMax then
		return string.format("Momentum: %s/%s%s", momentumCharge, momentumMax, momentumArmed == "Armed" and " Armed" or "")
	end
	momentumCharge, momentumArmed = gemTooltip:match("Momentum:%s*([%d%.%,]+)%s*(%a*)")
	if momentumCharge then
		return string.format("Momentum: %s%s", momentumCharge, momentumArmed == "Armed" and " Armed" or "")
	end

	local lifetimeDamage = gemTooltip:match("Lifetime Damage:%s*([%d%.%,]+)")
	if lifetimeDamage then
		return string.format("Lifetime Damage: %s", lifetimeDamage)
	end

	local lowerGemName = gemName:lower()

	if lowerGemName:find("cartel gem", 1, true) then
		local goldMultiplier, rarityPenalty = gemTooltip:match("Gold coin loot gains%s*%+([%d%.%,]+)x multiplier, but rarity loot chance is reduced by%s*([%d%.%,]+)%%")
		if goldMultiplier or rarityPenalty then
			return string.format("Gold Loot +%sx  Rarity Chance -%s%%", goldMultiplier or "0", rarityPenalty or "0")
		end
	end

	if lowerGemName:find("panic ward gem", 1, true) then
		local reduction = gemTooltip:match("gain speed and%s*([%d%.%,]+)%% damage reduction")
		if reduction then
			return string.format("Damage Reduction +%s%%", reduction)
		end
	end

	if lowerGemName:find("second skin gem", 1, true) then
		local reduction = gemTooltip:match("arms%s*([%d%.%,]+)%% reduction")
		if reduction then
			return string.format("Next Same Type Damage -%s%%", reduction)
		end
	end

	if lowerGemName:find("guardian pulse gem", 1, true) then
		local shieldPercent = gemTooltip:match("shields nearby party members for%s*([%d%.%,]+)%%")
		if shieldPercent then
			return string.format("Party Shield +%s%% Max HP", shieldPercent)
		end
	end

	if lowerGemName:find("rupture gem", 1, true) then
		local bleedPercent, maxStacks = gemTooltip:match("bleed for%s*([%d%.%,]+)%% of hit damage per stack%. Max%s*(%d+) stacks")
		if bleedPercent then
			return string.format("Bleed +%s%%/stack  Max %s", bleedPercent, maxStacks or "?")
		end
	end

	if lowerGemName:find("stoneblood gem", 1, true) then
		local resistance = gemTooltip:match("damage resistance, up to%s*([%d%.%,]+)%%")
		if resistance then
			return string.format("Damage Resistance up to %s%%", resistance)
		end
	end

	if lowerGemName:find("echo strike gem", 1, true) then
		local chance, damage = gemTooltip:match("attacks have%s*([%d%.%,]+)%% chance to echo.-for%s*([%d%.%,]+)%% damage")
		if chance or damage then
			return string.format("Echo %s%% chance  %s%% damage", chance or "0", damage or "0")
		end
	end

	if lowerGemName:find("executioner's mercy gem", 1, true) then
		local damage, threshold = gemTooltip:match("deals%s*%+([%d%.%,]+)%% damage to monsters below%s*([%d%.%,]+)%% HP")
		if damage or threshold then
			return string.format("Execute Damage +%s%% below %s%% HP", damage or "0", threshold or "0")
		end
	end

	if lowerGemName:find("memory gem", 1, true) then
		local rememberedName, rememberedDamage = gemTooltip:match("Remembered:%s*([^%n]+)%s+Damage%s*%+([%d%.%,]+)%%")
		if rememberedName and rememberedDamage then
			return string.format("Remembered: %s  Damage +%s%%", rememberedName:gsub("%s+$", ""), rememberedDamage)
		end

		local learningName, learningKills, learningRequired, learningDamage = gemTooltip:match("Learning:%s*(.-)%s+(%d+)%/(%d+)%s+Damage%s*%+([%d%.%,]+)%%")
		if learningName and learningKills and learningRequired and learningDamage then
			return string.format("Learning: %s %s/%s  Damage +%s%%", learningName:gsub("%s+$", ""), learningKills, learningRequired, learningDamage)
		end

		local noMemoryRequired, noMemoryDamage = gemTooltip:match("Memory:%s*No monster%s*0%/(%d+)%s+Damage%s*%+([%d%.%,]+)%%")
		if noMemoryRequired or noMemoryDamage then
			return string.format("No monster 0/%s  Damage +%s%%", noMemoryRequired or "0", noMemoryDamage or "0")
		end
	end

	local predatorName, predatorKills, predatorRequired = gemTooltip:match("Power:%s*([^,\n]+),%s*(%d+)%/(%d+)")
	if predatorName then
		if predatorName == "No prey" then
			return string.format("Learn a monster after %s kills", predatorRequired or "0")
		end

		if tonumber(predatorKills) and tonumber(predatorRequired) and tonumber(predatorKills) >= tonumber(predatorRequired) then
			return string.format("Learned: %s after %s kills", predatorName, predatorRequired)
		end

		return string.format("Learning: %s %s/%s", predatorName, predatorKills or "0", predatorRequired or "0")
	end

	local monsterKills = gemTooltip:match("Monsters Slain:%s*([%d%.%,]+)")
		or gemTooltip:match("Monster Kills:%s*([%d%.%,]+)")
	local bossKills = gemTooltip:match("Bosses Slain:%s*([%d%.%,]+)")
		or gemTooltip:match("Boss Kills:%s*([%d%.%,]+)")
	if monsterKills or bossKills then
		return string.format("Monsters: %s  Bosses: %s", monsterKills or "0", bossKills or "0")
	end

	local compact = gemName:match("Gold Looted:%s*([^|%n]+)")
		or gemName:match("Gold:%s*([^|%n]+)")
		or gemTooltip:match("Gold Looted:%s*([^\n]+)")
		or gemTooltip:match("Loot Gold Recorded:%s*([^\n]+)")

	if compact and compact ~= "" then
		return "Gold: " .. compact:gsub("^%s+", ""):gsub("%s+$", "")
	end

	if gemName:lower():find("treasury gem", 1, true) then
		return "Gold: 0"
	end

	return nil
end

local function getSocketGemDisplayName(gemName)
	gemName = tostring(gemName or "")
	return gemName
		:gsub("%s*|%s*Gold Looted:%s*[^|%n]+", "")
		:gsub("%s*|%s*Gold:%s*[^|%n]+", "")
		:gsub("%s*|%s*Health%s*%+[%d%.%,]+%s+Mana%s*%+[%d%.%,]+", "")
end

local function getStandaloneTreasuryGoldLine(gemTooltip)
	gemTooltip = tostring(gemTooltip or "")
	local compact = gemTooltip:match("Loot Gold Recorded:%s*([^\n]+)")
		or gemTooltip:match("Gold Looted:%s*([^\n]+)")
		or gemTooltip:match("Gold:%s*([^\n]+)")

	if not compact or compact == "" then
		return nil
	end

	local numericText = compact:gsub("[^%d]", "")
	if (tonumber(numericText) or 0) <= 0 then
		return nil
	end

	return "Gold: " .. compact:gsub("^%s+", ""):gsub("%s+$", "")
end

local function getStandaloneGravediggerPowerLine(gemTooltip)
	gemTooltip = tostring(gemTooltip or "")
	local health, mana = gemTooltip:match("Health%s*%+([%d%.%,]+)%s+Mana%s*%+([%d%.%,]+)")
	if not health or not mana then
		health, mana = gemTooltip:match("Bonus:%s*%+([%d%.%,]+)%s*max%s*HP,%s*%+([%d%.%,]+)%s*max%s*Mana")
	end

	if not health or not mana then
		return nil
	end

	local healthValue = tonumber(tostring(health):gsub("[^%d]", "")) or 0
	local manaValue = tonumber(tostring(mana):gsub("[^%d]", "")) or 0
	if healthValue <= 0 and manaValue <= 0 then
		return nil
	end

	return string.format("Health +%s Mana +%s", health, mana)
end

local function splitGemTooltipPreviewLines(text, maxLines, maxChars)
	text = tostring(text or ""):gsub("&#10;", "\n")
	maxLines = math.max(1, tonumber(maxLines) or 3)
	maxChars = math.max(24, tonumber(maxChars) or 96)
	local lines = {}

	local function pushWrappedLine(rawLine)
		rawLine = tostring(rawLine or ""):gsub("^%s+", ""):gsub("%s+$", "")
		while rawLine ~= "" and #lines < maxLines do
			if #rawLine <= maxChars then
				lines[#lines + 1] = rawLine
				return
			end

			local cut = maxChars
			for index = maxChars, 1, -1 do
				if rawLine:sub(index, index):match("%s") then
					cut = index - 1
					break
				end
			end

			lines[#lines + 1] = rawLine:sub(1, cut):gsub("%s+$", "")
			rawLine = rawLine:sub(cut + 1):gsub("^%s+", "")
		end
	end

	for rawLine in text:gmatch("[^\n]+") do
		if #lines >= maxLines then
			break
		end
		pushWrappedLine(rawLine)
	end

	return lines
end

local gemLevelData = m_TooltipFunction.getAttribute(list, m_TooltipFunction.TOOLTIP_ATTRIBUTE_GEM_LEVEL)
if gemLevelData and gemLevelData ~= "" then
	local gemLevel, gemMaxLevel, gemTooltip = gemLevelData:match("^([^|]*)|([^|]*)|(.*)$")
	gemLevel = tonumber(gemLevel) or 0
	gemMaxLevel = tonumber(gemMaxLevel) or 0
	if gemLevel > 0 and gemMaxLevel > 0 then
		height = m_TooltipFunction.addLabel("TooltipSeparator", height, width)
		height, width = m_TooltipFunction.addLabel("LookItemSectionTitle", height, width, "Gem Level", nil, "#f0c96a")
		local gemLevelTitle = m_TooltipList.list:getLastChild()
		if gemLevelTitle then
			gemLevelTitle:setTextAlign(AlignLeft)
			gemLevelTitle:setMarginLeft(16)
		end

		height, width = m_TooltipFunction.addLabel("LookItemIconAttribute", height, width, string.format("Level %d / %d", gemLevel, gemMaxLevel), 58, "#f0c96a")
		local starsRow = g_ui.createWidget("GemTooltipStarsRow", m_TooltipList.list)
		starsRow:setId("gemLevelStarsRow")
		starsRow:setMarginLeft(28)
		renderGemTooltipStars(starsRow, gemLevel, gemMaxLevel)
		height = height + starsRow:getHeight() + 4
		width = math.max(width, starsRow:getWidth() + 42)

		for index, line in ipairs(splitGemTooltipPreviewLines(gemTooltip, 3, 100)) do
			if index == 1 then
				height, width = m_TooltipFunction.addLabel("LookItemIconAttribute", height, width, line, 75, "#b8d6b0")
			else
				height, width = m_TooltipFunction.addLabel("LookItemContinuationAttribute", height - 4, width, line, nil, "#b8d6b0")
			end
		end
		local treasuryGoldLine = getStandaloneTreasuryGoldLine(gemTooltip)
		if treasuryGoldLine then
			height, width = m_TooltipFunction.addLabel("LookItemIconAttribute", height, width, treasuryGoldLine, 58, "#f0c96a")
		end
		local gravediggerPowerLine = getStandaloneGravediggerPowerLine(gemTooltip)
		if gravediggerPowerLine then
			height, width = m_TooltipFunction.addLabel("LookItemIconAttribute", height, width, gravediggerPowerLine, 58, "#f0c96a")
		end
	end
end

local forgeTierTooltipData = m_TooltipFunction.getAttribute(list, m_TooltipFunction.TOOLTIP_ATTRIBUTE_FORGE_TIER)
if forgeTierTooltipData and forgeTierTooltipData ~= "" then
	local forgeTier = tonumber(forgeTierTooltipData) or 0
	if forgeTier >= 1 and forgeTier <= 10 then
		height = m_TooltipFunction.addLabel("TooltipSeparator", height, width)
		local forgeTierRow = g_ui.createWidget("ForgeTierTooltipRow", m_TooltipList.list)
		forgeTierRow:setWidth(190)
		forgeTierRow:getChildById("tierLabel"):setText("Forge Tier:")
		forgeTierRow:getChildById("tierIcon"):setImageSource(
			"/modules/game_forge/images/" .. forgeTier
		)
		height = height + forgeTierRow:getHeight() + 4
		width = math.max(width, forgeTierRow:getWidth() + 16)
	end
end

local proficiencyModule = modules.game_proficiency
local proficiencySystem = proficiencyModule and proficiencyModule.WeaponProficiency
local proficiency = proficiencySystem and proficiencySystem:getTooltipProgress(m_TooltipList.itemId)
if proficiency then
	height = m_TooltipFunction.addLabel("TooltipSeparator", height, width)
	local proficiencyTitle
	height, width, proficiencyTitle = m_TooltipFunction.addLabel("LookItemSectionTitle", height, width, "Weapon Proficiency")
	if proficiencyTitle then
		proficiencyTitle:setTextAlign(AlignLeft)
		proficiencyTitle:setMarginLeft(16)
	end
	local row = g_ui.createWidget("ProficiencyTooltipRow", m_TooltipList.list)
	local progressText = "MAX"
	if proficiency.exp < proficiency.maxExp then
		progressText = string.format("Level %d / %d   %s / %s XP", proficiency.level,
			proficiency.maxLevel, comma_value(proficiency.exp), comma_value(proficiency.nextExp))
	end
	row:getChildById("proficiencyText"):setText(progressText)
	row:recursiveGetChildById("proficiencyBar"):setPercent(proficiency.percent)
	height = height + row:getHeight() + 4
	width = math.max(width, row:getWidth() + 24)
end

local gemTooltipData = m_TooltipFunction.getAttribute(list, m_TooltipFunction.TOOLTIP_ATTRIBUTE_GEMS)
if gemTooltipData and gemTooltipData ~= "" then
	height = m_TooltipFunction.addLabel("TooltipSeparator", height, width)
	height, width = m_TooltipFunction.addLabel("LookItemSectionTitle", height, width, "Socketed Gems", nil, "#f0c96a")
	local gemsTitleLabel = m_TooltipList.list:getLastChild()
	if gemsTitleLabel then
		gemsTitleLabel:setTextAlign(AlignLeft)
		gemsTitleLabel:setMarginLeft(16)
	end

	for entry in gemTooltipData:gmatch("([^;]+)") do
		local socketIndex, clientId, gemName, gemLevel, gemMaxLevel, gemTooltip = entry:match("^([^|]*)|([^|]*)|([^|]*)|([^|]*)|([^|]*)|(.*)$")
		if not socketIndex then
			socketIndex, clientId, gemName, gemTooltip = entry:match("^([^|]*)|([^|]*)|([^|]*)|(.*)$")
			gemLevel = 1
			gemMaxLevel = 1
		end

		if socketIndex and gemName then
			local hasDescription = gemTooltip and gemTooltip ~= "" and gemTooltip ~= "Empty socket"
			gemLevel = math.max(1, tonumber(gemLevel) or 1)
			gemMaxLevel = math.max(gemLevel, tonumber(gemMaxLevel) or gemLevel)
			local rowStyle = hasDescription and "GemTooltipRow" or "GemTooltipEmptyRow"
			local row = g_ui.createWidget(rowStyle, m_TooltipList.list)
			local socketLabel = row:getChildById("socketLabel")
			if socketLabel then
				socketLabel:setText("")
			end

			local gemItem = row:getChildById("gemItem")
			gemItem:setVirtual(true)
			gemItem:setItemId(tonumber(clientId) or 0)
			if hasDescription then
				gemItem:setImageSource("")
			end

			local gemText = row:recursiveGetChildById("gemText")
			local gemCompactText = row:recursiveGetChildById("gemCompactText")
			if hasDescription then
				local compactLine = getSocketGemCompactLine(gemName, gemTooltip)
				local displayName = getSocketGemDisplayName(gemName)
				gemText:setText(displayName)
				if gemCompactText then
					gemCompactText:setText(compactLine or "")
					local compactWidth = math.max(220, math.min(520, ((compactLine and #compactLine or 0) * 7) + 24))
					local textPanelWidth = compactWidth + 58
					local gemInfoLine = row:recursiveGetChildById("gemInfoLine")
					local gemTextPanel = row:recursiveGetChildById("gemTextPanel")
					if gemInfoLine then
						gemInfoLine:setWidth(textPanelWidth)
					end
					if gemTextPanel then
						gemTextPanel:setWidth(textPanelWidth)
					end
					gemText:setWidth(textPanelWidth)
					gemCompactText:setWidth(compactWidth)
					row:setWidth(textPanelWidth + 44)
				end
				renderGemTooltipStars(row, gemLevel, gemMaxLevel)
			else
				gemText:setText(getSocketGemDisplayName(gemName))
				if gemCompactText then
					gemCompactText:setText("")
				end
			end

			height = height + row:getHeight() + 4
			width = math.max(width, row:getWidth() + 24)
		end
	end
end

m_TooltipList.window:setWidth(width)
m_TooltipList.window:setHeight(height)
if options.compare and options.anchorWindow then
	placeTooltipBeside(m_TooltipList.window, options.anchorWindow, 12)
else
	placeTooltipAtCursor(m_TooltipList.window, m_TooltipList.position, 16)
end

m_TooltipList[windowField] = m_TooltipList.window
m_TooltipList[listField] = m_TooltipList.list
if options.compare then
	m_TooltipList.window = savedWindow
	m_TooltipList.list = savedList
	m_TooltipList.itemId = savedItemId
	m_TooltipList.position = savedPosition
end
end

rawset(_G, 'm_TooltipFunction', m_TooltipFunction)
rawset(_G, 'm_TooltipList', m_TooltipList)
