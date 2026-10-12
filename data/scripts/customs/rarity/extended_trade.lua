local OPCODE_RARITY_TRADE = 211
local FORGE_TIER_ATTRIBUTE = "forge_tier"

local function getItemForgeTier(item)
  if not item then return 0 end
  local tier = tonumber(item:getCustomAttribute(FORGE_TIER_ATTRIBUTE)) or 0
  return (tier >= 1 and tier <= 10) and math.floor(tier) or 0
end

local evt = CreatureEvent("rarityFramesTrade")
function evt.onExtendedOpcode(player, opcode, buffer)
  if opcode ~= OPCODE_RARITY_TRADE then return true end

  local ok, data = pcall(function() return json.decode(buffer) end)
  if not ok or type(data) ~= "table" then return true end

  if data.a == "reqT" and type(data.s) == "number" then
    local side  = data.s
    local items = TradeRarity_getItems(player, side)
    local out   = {}
    for i = 1, #items do
      local it = items[i]
      local rarityNum = 0
      if it and not it:isContainer() then
        rarityNum = TradeRarity_numberFromItem(it)
      end
      out[#out+1] = { i-1, rarityNum, getItemForgeTier(it) }
    end
    player:sendExtendedOpcode(OPCODE_RARITY_TRADE, json.encode({ a="rarT", s=side, m=out }))
  elseif data.a == "reqTS" and type(data.s)=="number" and type(data.i)=="number" then
    local it  = TradeRarity_getItemAt(player, data.s, data.i)
    local num = TradeRarity_numberFromItem(it)
    player:sendExtendedOpcode(OPCODE_RARITY_TRADE, json.encode({
      a="rarTS", s=data.s, i=data.i, n=num, t=getItemForgeTier(it)
    }))
  end
  return true
end
evt:type("extendedopcode")
evt:register()

local login = CreatureEvent("rarityLoginTrade")
function login.onLogin(player)
  player:registerEvent("rarityFramesTrade")
  return true
end
login:type("login")
login:register()
