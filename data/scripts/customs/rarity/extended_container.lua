local OPCODE_RARITY_CONTAINER = 209
local RARITY_BASE   = 63500
local FORGE_TIER_ATTRIBUTE = "forge_tier"
local RARITY_OPCODE_CHUNK_SIZE = 7900

local function sendRarityJson(player, payload)
  local encoded = type(payload) == "string" and payload or json.encode(payload)
  if #encoded <= RARITY_OPCODE_CHUNK_SIZE then
    player:sendExtendedOpcode(OPCODE_RARITY_CONTAINER, encoded)
    return
  end

  local index = 1
  while index <= #encoded do
    local chunk = encoded:sub(index, index + RARITY_OPCODE_CHUNK_SIZE - 1)
    local prefix = "P"
    if index == 1 then
      prefix = "S"
    elseif index + RARITY_OPCODE_CHUNK_SIZE > #encoded then
      prefix = "E"
    end

    player:sendExtendedOpcode(OPCODE_RARITY_CONTAINER, prefix .. chunk)
    index = index + RARITY_OPCODE_CHUNK_SIZE
  end
end

local function getItemRarityId(item)
  local rid = item:getCustomAttribute("rarity")
  if rid and type(rid) == "number" and rid > 0 then
    return rid
  end
  return 0
end

local function getItemForgeTier(item)
  if not item then return 0 end
  local tier = tonumber(item:getCustomAttribute(FORGE_TIER_ATTRIBUTE)) or 0
  return (tier >= 1 and tier <= 10) and math.floor(tier) or 0
end

local function replyContainerRarities(player, contId)
  local container = player:getContainerById(contId)
  if not container then
    return
  end

  local cap = container:getCapacity()
  local out = {}
  for slot = 0, cap - 1 do
    local item = container:getItem(slot)
    local num = 0
    if item then
      local rid = getItemRarityId(item)
      if rid and rid > 0 then
        num = RARITY_BASE + rid
      end
    end
    table.insert(out, {slot, num, getItemForgeTier(item)})
  end

  local payload = { a = "rarR", c = contId, m = out }
  sendRarityJson(player, payload)
end

local rarityOpcode = CreatureEvent("rarityFramesContainer")
function rarityOpcode.onExtendedOpcode(player, opcode, buffer)
  if opcode ~= OPCODE_RARITY_CONTAINER then return true end

  local ok, data = pcall(function() return json.decode(buffer) end)
  if not ok or type(data) ~= "table" then
    return true
  end

  if data.a == "reqR" then
    replyContainerRarities(player, data.c)

  elseif data.a == "reqRS" then
    local container = player:getContainerById(data.c)
    local num = 0
    local item = nil
    if container then
      item = container:getItem(data.s)
      if item then
        local rid = getItemRarityId(item)
        if rid and rid > 0 then num = RARITY_BASE + rid end
      end
    end
    local payload = { a="rarRS", c=data.c, s=data.s, n=num, t=getItemForgeTier(item) }
    sendRarityJson(player, payload)
  end
  return true
end

rarityOpcode:type("extendedopcode")
rarityOpcode:register()


local LoginEvent = CreatureEvent("rarityLoginContainer")
function LoginEvent.onLogin(player)
  player:registerEvent("rarityFramesContainer")
  return true
end
LoginEvent:type("login")
LoginEvent:register()
