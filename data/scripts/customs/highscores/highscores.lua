
local EXT_OP    = 73

local SKILL_COLUMNS = {
  [1] = "skill_sword",
  [2] = "skill_axe",
  [3] = "skill_club",
  [4] = "skill_dist",
  [5] = "skill_shielding",
  --- 6 is magic level, don't touch
  [7] = "skill_fist",
  [8] = "skill_mining",
  [9] = "skill_fishing",
  [10] = "skill_woodcutting",
  [11] = "skill_herbalist",
  [12] = "skill_crafting",
  [13] = "skill_weaponsmith",
  [14] = "skill_armorsmith",
  [15] = "skill_jewelsmith",
  [16] = "ancestral_points",
  [17] = "ancestral_rank_points",
}

local highscoreEvent = CreatureEvent("highscoresRequest")
function highscoreEvent.onExtendedOpcode(player, opcode, buffer)
  if opcode ~= EXT_OP then return end

  local ok, req = pcall(json.decode, buffer)
  if not ok or type(req) ~= "table" then return false end

  local category    = tonumber(req.category) or 0
  local vocation    = tonumber(req.vocation) or 0
  local page        = math.max(1, tonumber(req.page) or 1)
  local perPage     = math.max(1, tonumber(req.entriesPerPage) or 10)
  local showOwnRank = tonumber(req.type) or 0
  local vocs        = req.vocations or {}
  if #vocs == 0 then vocs = { vocation } end
  local vocFilter = table.concat(vocs, ",")

  local countQ = db.storeQuery(
    ("SELECT COUNT(*) AS total FROM `players` WHERE `vocation` IN (%s)")
    :format(vocFilter)
  )
  local totalRows = 0
  if countQ then
    totalRows = result.getDataInt(countQ, "total")
    result.free(countQ)
  end
  local totalPages = math.max(1, math.ceil(totalRows / perPage))

  local col
  if category == 0 then
    col = "`experience`"
  elseif category == 6 then
    col = "`maglevel`"
  else
    col = "`" .. (SKILL_COLUMNS[category] or error("invalid category")) .. "`"
  end

  -- fetch this page
  local offset = (page - 1) * perPage
  local sql = ([[
    SELECT
      p.`name`,
      p.`vocation`,
      p.`level`,
      %s AS `experience`,
      p.`looktype`, p.`lookhead`, p.`lookbody`, p.`looklegs`, p.`lookfeet`, p.`lookaddons`, p.`wings_id`, p.`aura_id`, p.`shader_id`
    FROM `players` p
    WHERE p.`vocation` IN (%s)
    ORDER BY %s DESC
    LIMIT %d,%d
  ]]):format(col, vocFilter, col, offset, perPage)

  local q = db.storeQuery(sql)
  local rows = {}
  if q then
    repeat
      local nm  = result.getDataString(q, "name")
      local voc = result.getDataInt(q,    "vocation")
      local lvl = result.getDataInt(q,    "level")
      local exp = result.getDataLong(q,   "experience")
      local lt  = result.getDataInt(q,   "looktype")
      local lh  = result.getDataInt(q,   "lookhead")
      local lb  = result.getDataInt(q,   "lookbody")
      local ll  = result.getDataInt(q,   "looklegs")
      local lf  = result.getDataInt(q,   "lookfeet")
      local la  = result.getDataInt(q,   "lookaddons")
      local wings  = result.getDataInt(q, "wings_id")
      local aura   = result.getDataInt(q, "aura_id")
      local shader = result.getDataInt(q, "shader_id")
      local isOnline = Player(nm) and 1 or 0

      table.insert(rows, {
        rank       = 0,    -- fill below
        name       = nm,
        vocation   = voc,
        level      = lvl,
        experience = exp,
        online     = isOnline,
        lookType   = lt,
        lookHead   = lh,
        lookBody   = lb,
        lookLegs   = ll,
        lookFeet   = lf,
        lookAddons = la,
        wingsId    = wings,
        auraId     = aura,
        shaderId   = shader,
      })
    until not result.next(q)
    result.free(q)
  end

  for i,entry in ipairs(rows) do
    entry.rank = offset + i
  end

  if showOwnRank == 1 then
    local me = player:getName()
    for _, entry in ipairs(rows) do
      if entry.name == me then
        rows = { entry }
        pages = 1
        page  = 1
        break
      end
    end
  end

  local resp = {
    action   = "highscore",
    category = category,
    page     = page,
    pages    = totalPages,
    data     = rows,
  }
  player:sendExtendedOpcode(EXT_OP, json.encode(resp))
  return true
end
highscoreEvent:register()

local LoginEvent = CreatureEvent("highscoresLogin")
function LoginEvent.onLogin(player)
  player:registerEvent("highscoresRequest")
  return true
end
LoginEvent:type("login")
LoginEvent:register()

local LogoutEvent = CreatureEvent("highscoresLogout")
function LogoutEvent.onLogout(player)
  player:unregisterEvent("highscoresRequest")
  return true
end
LogoutEvent:type("logout")
LogoutEvent:register()
