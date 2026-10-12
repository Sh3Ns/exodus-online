if not ExtendedOPCodes then
  ExtendedOPCodes = {}
end
ExtendedOPCodes.BOSS_TIMERS = ExtendedOPCodes.BOSS_TIMERS or 221

BossTimers = BossTimers or {}
BossTimers.opcode = ExtendedOPCodes.BOSS_TIMERS
BossTimers.pageSize = 10

BossTimers.playerBosses = {
  -- Bakragore
  {id = 'bakragore', name = 'Bakragore', lookType = 1092, category = 'Bakragore', storage = 710091, cooldown = 36000},
  {id = 'chagorz', name = 'Chagorz', lookType = 1090, category = 'Bakragore', storage = 710042, cooldown = 14400},
  {id = 'ichgahal', name = 'Ichgahal', lookType = 1089, category = 'Bakragore', storage = 710043, cooldown = 14400},
  {id = 'murcion', name = 'Murcion', lookType = 1088, category = 'Bakragore', storage = 710044, cooldown = 14400},
  {id = 'vemiath', name = 'Vemiath', lookType = 1091, category = 'Bakragore', storage = 710051, cooldown = 14400},

  -- Cobra / Falcon / Lion
  {id = 'scarlett_etzel', name = 'Scarlett Etzel', lookType = 1006, category = 'Cobra Bastion', storage = 24854, cooldown = 20 * 60 * 60},
  {id = 'grand_master_oberon', name = 'Grand Master Oberon', lookType = 1002, category = 'Falcon Bastion', storage = 720018, cooldown = 7200},
  {id = 'furious_scorpion', name = 'Furious Scorpion', lookType = 398, category = 'Lion Sanctum', storage = 720028, cooldown = 86400},

  -- Fear Feaster / Dream Courts
  {id = 'vok_the_freakish_1', name = 'Unaz The Mean', lookType = 1031, lookBody = 95, category = 'Fear Feaster Mini', storage = 194505, cooldown = 1800},
  {id = 'irgix_the_flimsy', name = 'Irgix the Flimsy', lookType = 1029, lookFeet = 94, category = 'Fear Feaster Mini', storage = 194506, cooldown = 1800},
  {id = 'vok_the_freakish_2', name = 'Vok The Freakish', lookType = 1031, lookBody = 98, lookFeet = 94, category = 'Fear Feaster Mini', storage = 194507, cooldown = 1800},
  {id = 'the_dread_maiden', name = 'The Dread Maiden', lookType = 1032, category = 'Fear Feaster', storage = 720019, cooldown = 7200},
  {id = 'the_fear_feaster', name = 'The Fear Feaster', lookType = 1033, category = 'Fear Feaster', storage = 720023, cooldown = 7200},
  {id = 'the_pale_worm', name = 'The Pale Worm', lookType = 1034, category = 'Fear Feaster', storage = 720021, cooldown = 7200},
  {id = 'the_unwelcome', name = 'The Unwelcome', lookType = 1035, category = 'Fear Feaster', storage = 720022, cooldown = 7200},

  -- Grave Danger
  {id = 'count_vlarkorth', name = 'Count Vlarkorth', lookType = 1009, lookHead = 19, lookLegs = 83, lookFeet = 20, lookAddons = 1, category = 'Grave Danger', storage = 720025, cooldown = 1800},
  {id = 'duke_krule', name = 'Duke Krule', lookType = 1009, lookHead = 8, lookBody = 8, lookLegs = 19, lookFeet = 79, lookAddons = 3, category = 'Grave Danger', storage = 720026, cooldown = 1800},
  {id = 'earl_osam', name = 'Earl Osam', lookType = 1011, lookHead = 113, lookLegs = 79, lookFeet = 95, category = 'Grave Danger', storage = 720027, cooldown = 1800},
  {id = 'king_zelos', name = 'King Zelos', lookType = 1012, category = 'Grave Danger', storage = 739428, cooldown = 14400},
  {id = 'lord_azaram', name = 'Lord Azaram', lookType = 1011, lookHead = 19, lookBody = 2, lookLegs = 94, lookFeet = 81,  lookAddons = 3, category = 'Grave Danger', storage = 720841, cooldown = 1800},
  {id = 'sir_baeloc', name = 'Sir Baeloc', lookType = 1010, lookHead = 57, lookBody = 81, lookLegs = 3, lookFeet = 93, lookAddons = 1, category = 'Grave Danger', storage = 720130, cooldown = 1800},

  -- Lion mini bosses
  {id = 'srezz_yellow_eyes', name = 'Srezz Yellow Eyes', lookType = 220, category = 'Lion Mini', storage = 194508, cooldown = 14400},
  {id = 'yirkas_blue_scales', name = 'Yirkas Blue Scales', lookType = 1029, category = 'Lion Mini', storage = 194509, cooldown = 14400},
  {id = 'katex_blood_tongue', name = 'Katex Blood Tongue', lookType = 1047, lookHead = 76, lookBody = 57, lookLegs = 113, lookFeet = 113, category = 'Lion Mini', storage = 194510, cooldown = 14400},

  -- Secret Library
  {id = 'gorzindel', name = 'Gorzindel', lookType = 990, lookHead = 94, lookBody = 81, lookLegs = 10, lookAddons = 1, category = 'Secret Library', storage = 720015, cooldown = 7200},
  {id = 'ghulosh', name = 'Ghulosh', lookType = 990, lookHead = 78, lookBody = 113, lookLegs = 94, lookFeet = 18, lookAddons = 3, category = 'Secret Library', storage = 720214, cooldown = 7200},
  {id = 'lokathmor', name = 'Lokathmor', lookType = 990, lookHead = 22, lookBody = 57, lookLegs = 79, lookFeet = 77, lookAddons = 0, category = 'Secret Library', storage = 720016, cooldown = 7200},
  {id = 'mazzinor', name = 'Mazzinor', lookType = 990, lookHead = 85, lookBody = 7, lookLegs = 3, lookFeet = 15, lookAddons = 2, category = 'Secret Library', storage = 720017, cooldown = 7200},
  {id = 'the_scourge_of_oblivion', name = 'The Scourge of Oblivion', lookType = 875, lookHead = 79, lookBody = 3, lookLegs = 4, lookFeet = 2, lookAddons = 3, category = 'Secret Library', storage = 720119, cooldown = 14400},

  -- Soul War
  {id = 'goshnar_malice', name = "Goshnar's Malice", lookType = 1053, category = 'Soul War', storage = 720040, cooldown = 7200},
  {id = 'goshnar_hatred', name = "Goshnar's Hatred", lookType = 1054, category = 'Soul War', storage = 720041, cooldown = 7200},
  {id = 'goshnar_spite', name = "Goshnar's Spite", lookType = 1052, category = 'Soul War', storage = 720042, cooldown = 7200},
  {id = 'goshnar_cruelty', name = "Goshnar's Cruelty", lookType = 1050, category = 'Soul War', storage = 720043, cooldown = 7200},
  {id = 'goshnar_megalomania', name = "Goshnar's Megalomania", lookType = 1055, category = 'Soul War', storage = 720044, cooldown = 7200},
  {id = 'goshnar_greed', name = "Goshnar's Greed", lookType = 1051, category = 'Soul War', storage = 720045, cooldown = 7200},

  -- Custom quests
  {id = 'arodis_saron', name = 'Arodis Saron', lookType = 1226, category = 'Custom Quest', storage = 720072, cooldown = 7200},
  {id = 'astro_king', name = 'Astro King', lookType = 1209, category = 'Custom Quest', storage = 723371, cooldown = 7200},
  {id = 'blessed_archangel', name = 'Blessed Archangel', lookType = 1223, category = 'Custom Quest', storage = 720036, cooldown = 14400},
  {id = 'candy_fairy', name = 'Candy Fairy', lookType = 1288, lookHead = 81, lookBody = 96, lookLegs = 104, lookFeet = 18, lookAddons = 3, category = 'Candia', storage = 720076, cooldown = 7200},
  {id = 'sugar_daddy', name = 'Sugar Daddy', lookType = 1298, category = 'Candia', storage = 720075, cooldown = 7200},
  {id = 'mercurial_mage', name = 'Mercurial Mage', lookType = 1227, category = 'Custom Quest', storage = 720073, cooldown = 7200},

  -- Waystone bosses
  {id = 'vorgrun_jade_1', name = 'Vorgrun Map 1', lookType = 1429, scale = 0.65, category = 'Waystone Boss', storage = 720172, cooldown = 500},
  {id = 'vorgrun_jade_2', name = 'Vorgrun Map 2', lookType = 1429, scale = 0.65, category = 'Waystone Boss', storage = 720173, cooldown = 500},
  {id = 'fractalis_1', name = 'Fractalis Map 1', lookType = 1425, scale = 0.65, category = 'Waystone Boss', storage = 720174, cooldown = 500},
  {id = 'fractalis_2', name = 'Fractalis Map 2', lookType = 1425, scale = 0.65, category = 'Waystone Boss', storage = 720175, cooldown = 500},
  {id = 'frostreaver_1', name = 'Frostreaver Map 1', lookType = 1427, scale = 0.65, category = 'Waystone Boss', storage = 720176, cooldown = 500},
  {id = 'frostreaver_2', name = 'Frostreaver Map 2', lookType = 1427, scale = 0.65, category = 'Waystone Boss', storage = 720177, cooldown = 500},
  {id = 'rhazgor_1', name = 'Rhazgor Map 1', lookType = 1428, scale = 0.65, category = 'Waystone Boss', storage = 720178, cooldown = 500},
  {id = 'rhazgor_2', name = 'Rhazgor Map 2', lookType = 1428, scale = 0.65, category = 'Waystone Boss', storage = 720179, cooldown = 500},
  {id = 'morgrath_1', name = 'Morgrath Map 1', lookType = 1424, scale = 0.60, category = 'Waystone Boss', storage = 720180, cooldown = 500},
  {id = 'morgrath_2', name = 'Morgrath Map 2', lookType = 1424, scale = 0.60, category = 'Waystone Boss', storage = 720181, cooldown = 500},
  {id = 'nyxdrath_1', name = 'Nyxdrath Map 1', lookType = 1426, scale = 0.60, category = 'Waystone Boss', storage = 720182, cooldown = 500},
  {id = 'nyxdrath_2', name = 'Nyxdrath Map 2', lookType = 1426, scale = 0.60, category = 'Waystone Boss', storage = 720183, cooldown = 500},

  -- Necromantic
  {id = 'vladrukh', name = 'Vladrukh', lookType = 1443, category = 'Necromantic', storage = 720184, cooldown = 600},
  {id = 'bone_overlord', name = 'Bone Overlord', lookType = 0, lookTypeEx = 30139, category = 'Necromantic', storage = 720185, cooldown = 600},
  -- Azure
  {id = 'azure', name = 'Azure', lookType = 964, category = 'Azure Portal', storage = 720020, cooldown = 14400},

  -- Warzone
  {id = 'deathstrike', name = 'Deathstrike', lookType = 500, category = 'Warzone', storage = 790015, cooldown = 10 * 60 * 60},
  {id = 'gnomevil', name = 'Gnomevil', lookType = 504, category = 'Warzone', storage = 790014, cooldown = 10 * 60 * 60},
  {id = 'abyssador', name = 'Abyssador', lookType = 495, category = 'Warzone', storage = 790016, cooldown = 10 * 60 * 60},

  -- Others
  {id = 'urmahlullu_the_immaculate', name = 'Urmahlullu the Immaculate', lookType = 1018, category = 'Custom Quest', storage = 28177, cooldown = 20 * 60 * 60},
  {id = 'destabilized_ferumbras', name = 'Destabilized Ferumbras', lookType = 844, category = 'Ferumbras', storage = 93521, cooldown = 50 * 60},
  {id = 'plagirath', name = 'Plagirath', lookType = 862, lookHead = 83, lookBody = 61, lookLegs = 98, lookFeet = 79, lookAddons = 1, category = 'Custom Quest', storage = 93523, cooldown = 20 * 60},
}

BossTimers.worldBosses = {
  {id = 'dreadscale_the_ancient', name = 'Dreadscale', lookType = 1169, scale = 0.60, category = 'World Boss', day = 'Sunday', time = '0:00:00'},
  {id = 'aquatic_overlord_thalassa', name = 'Aquatic', lookType = 1175, scale = 0.60, category = 'World Boss', day = 'Monday', time = '16:00:00'},
  {id = 'drakthul_void_sovereign', name = "Drak'thul", lookType = 1134, scale = 0.60, category = 'World Boss', day = 'Tuesday', time = '20:00:00'},
  {id = 'thalador_stormbringer', name = 'Thalador', lookType = 1133, scale = 0.60, category = 'World Boss', day = 'Wednesday', time = '20:00:00'},
  {id = 'vorondor_eternal_flames', name = 'Vorondor', lookType = 1132, scale = 0.60, category = 'World Boss', day = 'Thursday', time = '20:00:00'},
  {id = 'azazel_infernal_seraph', name = 'Azazel', lookType = 1145, scale = 0.60, category = 'World Boss', day = 'Friday', time = '20:00:00'},
  {id = 'mortis_sovereign', name = 'Mortis', lookType = 1168, scale = 0.60, category = 'World Boss', day = 'Saturday', time = '12:00:00'},
  {id = 'dreadbone_eternal', name = 'Dreadbone', lookType = 1167, scale = 0.60, category = 'World Boss', day = 'Saturday', time = '12:00:00'},
  {id = 'tymagron_earthshaker', name = 'Tymagron', lookType = 1136, scale = 0.60, category = 'World Boss', day = 'Saturday', time = '20:00:00'},
  {id = 'gorgul_frienzied', name = "Gor'gul", lookType = 1176, scale = 0.60, category = 'World Boss', day = 'Sunday', time = '20:00:00'},
    -- Corruption Bosses
  {
    id = 'gravexon_the_devourer',
    name = 'Gravexon The Devourer',
    lookType = 1495,
    scale = 0.60,
    category = 'Corruption Boss',
    schedules = {
      {day = 'Monday', time = '12:00:00'},
      {day = 'Wednesday', time = '13:00:00'},
      {day = 'Friday', time = '20:30:00'},
      {day = 'Sunday', time = '11:30:00'},
    }
  },
  {
    id = 'kaeldrath_the_fallen',
    name = 'Kaeldrath The Fallen',
    lookType = 1496,
    scale = 0.60,
    category = 'Corruption Boss',
    schedules = {
      {day = 'Monday', time = '18:00:00'},
      {day = 'Tuesday', time = '18:00:00'},
      {day = 'Thursday', time = '18:00:00'},
      {day = 'Saturday', time = '18:00:00'},
    }
  },
  {
    id = 'velkorth_the_plaguebringer',
    name = 'Velkorth The Plaguebringer',
    lookType = 1497,
    scale = 0.60,
    category = 'Corruption Boss',
    schedules = {
      {day = 'Monday', time = '12:00:00'},
      {day = 'Wednesday', time = '13:00:00'},
      {day = 'Friday', time = '20:30:00'},
      {day = 'Sunday', time = '11:30:00'},
    }
  },
  {
    id = 'zorgrath_the_carrion',
    name = 'Zorgrath The Carrion',
    lookType = 1498,
    scale = 0.60,
    category = 'Corruption Boss',
    schedules = {
      {day = 'Tuesday', time = '10:00:00'},
      {day = 'Wednesday', time = '10:00:00'},
      {day = 'Thursday', time = '10:00:00'},
      {day = 'Friday', time = '10:00:00'},
    }
  },
  {
    id = 'velkyrion_the_fractured',
    name = 'Velkyrion The Fractured',
    lookType = 1499,
    scale = 0.60,
    category = 'Corruption Boss',
    schedules = {
      {day = 'Monday', time = '15:00:00'},
      {day = 'Wednesday', time = '15:00:00'},
      {day = 'Saturday', time = '15:00:00'},
      {day = 'Sunday', time = '15:00:00'},
    }
  },
  {
    id = 'kraxxis_the_corruptor',
    name = 'Kraxxis The Corruptor',
    lookType = 1500,
    scale = 0.60,
    category = 'Corruption Boss',
    schedules = {
      {day = 'Monday', time = '20:00:00'},
      {day = 'Wednesday', time = '20:00:00'},
      {day = 'Saturday', time = '20:00:00'},
    }
  },
  {
    id = 'kraxxis_avatar_of_corruption',
    name = 'Kraxxis Avatar of Corruption',
    lookType = 1502,
    scale = 0.60,
    category = 'Corruption Boss',
    schedules = {
      {day = 'Tuesday', time = '21:00:00'},
      {day = 'Friday', time = '21:00:00'},
    }
  },
  {
    id = 'rathmora_the_blood_tyrant',
    name = 'Rathmora The Blood Tyrant',
    lookType = 1501,
    scale = 0.60,
    category = 'Corruption Boss',
    schedules = {
      {day = 'Tuesday', time = '20:00:00'},
      {day = 'Thursday', time = '20:00:00'},
      {day = 'Sunday', time = '20:00:00'},
    }
  },
  {
    id = 'rathmora_ascendant_tyrant',
    name = 'Rathmora Ascendant Tyrant',
    lookType = 1503,
    scale = 0.60,
    category = 'Corruption Boss',
    schedules = {
      {day = 'Thursday', time = '21:00:00'},
      {day = 'Saturday', time = '21:00:00'},
    }
  },
}

local dayIndex = {
  Sunday = 1,
  Monday = 2,
  Tuesday = 3,
  Wednesday = 4,
  Thursday = 5,
  Friday = 6,
  Saturday = 7,
}

local function parseTime(value)
  local h, m, s = tostring(value):match('^(%d+):(%d+):(%d+)$')
  return tonumber(h) or 0, tonumber(m) or 0, tonumber(s) or 0
end

local function getNextWeeklyTimestamp(dayName, timeText, now)
  now = now or os.time()
  local today = dayIndex[os.date('%A', now)] or 1
  local target = dayIndex[dayName] or today
  local daysAhead = (target - today) % 7
  local h, m, s = parseTime(timeText)
  local t = os.date('*t', now)
  t.hour = h
  t.min = m
  t.sec = s
  local candidate = os.time(t) + daysAhead * 24 * 60 * 60
  if candidate <= now then
    candidate = candidate + 7 * 24 * 60 * 60
  end
  return candidate
end

local function getClientItemId(serverItemId)
  serverItemId = tonumber(serverItemId) or 0
  if serverItemId <= 0 then
    return 0
  end

  local itemType = ItemType(serverItemId)
  if itemType and itemType:getId() ~= 0 then
    return itemType:getClientId()
  end

  return 0
end

local function addPlayerBossPayload(player, payload, entry, now)
  local value = player:getStorageValue(entry.storage)
  local status = 'ready'
  local remaining = 0

  if value and value > now then
    status = 'cooldown'
    remaining = value - now
  end

  local boss = {
    n = entry.name,
    l = entry.lookType or 0,
    c = entry.category or 'Boss',
    s = status,
    r = remaining,
    t = 'p',
  }

  if entry.lookTypeEx and entry.lookTypeEx > 0 then
    local clientItemId = getClientItemId(entry.lookTypeEx)
    if clientItemId > 0 then
      boss.x = clientItemId
    end
  end

  if entry.lookHead and entry.lookHead > 0 then
    boss.h = entry.lookHead
  end

  if entry.lookBody and entry.lookBody > 0 then
    boss.b = entry.lookBody
  end

  if entry.lookLegs and entry.lookLegs > 0 then
    boss.g = entry.lookLegs
  end

  if entry.lookFeet and entry.lookFeet > 0 then
    boss.f = entry.lookFeet
  end

  if entry.lookAddons and entry.lookAddons > 0 then
    boss.a = entry.lookAddons
  end

  if entry.lookMount and entry.lookMount > 0 then
    boss.m = entry.lookMount
  end

  if entry.scale and entry.scale ~= 1 then
    boss.z = entry.scale
  end

  payload[#payload + 1] = boss
end

local function getNextBossSchedule(entry, now)
  now = now or os.time()

  -- Nouveau format: schedules = {{day = 'Monday', time = '12:00:00'}, ...}
  if entry.schedules then
    local bestTimestamp = nil
    local bestSchedule = nil

    for _, schedule in ipairs(entry.schedules) do
      local timestamp = getNextWeeklyTimestamp(schedule.day, schedule.time, now)
      if not bestTimestamp or timestamp < bestTimestamp then
        bestTimestamp = timestamp
        bestSchedule = schedule
      end
    end

    return bestTimestamp, bestSchedule
  end

  -- Ancien format: day = 'Monday', time = '12:00:00'
  local timestamp = getNextWeeklyTimestamp(entry.day, entry.time, now)
  return timestamp, {
    day = entry.day,
    time = entry.time
  }
end

local function addWorldBossPayload(payload, entry, now)
  local nextSpawn, schedule = getNextBossSchedule(entry, now)

  local boss = {
    n = entry.name,
    l = entry.lookType or 0,
    c = entry.category or 'World Boss',
    s = 'scheduled',
    r = nextSpawn - now,
    d = schedule and schedule.day or entry.day,
    time = schedule and schedule.time or entry.time,
    t = 's',
  }

  if entry.lookTypeEx and entry.lookTypeEx > 0 then
    local clientItemId = getClientItemId(entry.lookTypeEx)
    if clientItemId > 0 then
      boss.x = clientItemId
    end
  end

  if entry.lookHead and entry.lookHead > 0 then
    boss.h = entry.lookHead
  end

  if entry.lookBody and entry.lookBody > 0 then
    boss.b = entry.lookBody
  end

  if entry.lookLegs and entry.lookLegs > 0 then
    boss.g = entry.lookLegs
  end

  if entry.lookFeet and entry.lookFeet > 0 then
    boss.f = entry.lookFeet
  end

  if entry.lookAddons and entry.lookAddons > 0 then
    boss.a = entry.lookAddons
  end

  if entry.lookMount and entry.lookMount > 0 then
    boss.m = entry.lookMount
  end

  if entry.scale and entry.scale ~= 1 then
    boss.z = entry.scale
  end

  payload[#payload + 1] = boss
end

local function collectBossTimers(player)
  local now = os.time()
  local bosses = {}

  for _, entry in ipairs(BossTimers.playerBosses) do
    addPlayerBossPayload(player, bosses, entry, now)
  end

  for _, entry in ipairs(BossTimers.worldBosses) do
    addWorldBossPayload(bosses, entry, now)
  end

  table.sort(bosses, function(a, b)
    local order = {cooldown = 1, scheduled = 2, ready = 3, active = 4, unknown = 5}

    local statusA = a.s or a.status or 'unknown'
    local statusB = b.s or b.status or 'unknown'

    local oa = order[statusA] or 9
    local ob = order[statusB] or 9

    if oa ~= ob then
      return oa < ob
    end

    if statusA == 'cooldown' or statusA == 'scheduled' then
      return (a.r or a.remaining or 0) < (b.r or b.remaining or 0)
    end

    return tostring(a.n or a.name) < tostring(b.n or b.name)
  end)

  return bosses, now
end

local function paginateBosses(bosses, page, pageSize)
  local totalBosses = #bosses
  local totalPages = math.max(1, math.ceil(totalBosses / pageSize))
  page = math.max(1, math.min(totalPages, tonumber(page) or 1))

  local fromIndex = ((page - 1) * pageSize) + 1
  local toIndex = math.min(fromIndex + pageSize - 1, totalBosses)
  local pageBosses = {}

  for index = fromIndex, toIndex do
    pageBosses[#pageBosses + 1] = bosses[index]
  end

  return pageBosses, page, totalPages, totalBosses
end

function BossTimers.getPayload(player, page)
  local bosses, now = collectBossTimers(player)
  local pageSize = math.max(1, tonumber(BossTimers.pageSize) or 10)
  local pageBosses, currentPage, totalPages, totalBosses = paginateBosses(bosses, page, pageSize)

  return {
    action = 'state',
    now = now,
    bosses = pageBosses,
    page = currentPage,
    totalPages = totalPages,
    totalBosses = totalBosses,
    pageSize = pageSize,
  }
end

function BossTimers.send(player, page)
  if not player then
    return false
  end

  local payload = BossTimers.getPayload(player, page)
  local encoded = json.encode(payload)

  if not encoded then
    print("[BossTimers] Failed to encode JSON payload.")
    return false
  end

  if #encoded > 8000 then
    print("[BossTimers] Payload too large: " .. #encoded .. " bytes. Boss timers not sent.")
    return false
  end
  player:sendExtendedOpcode(BossTimers.opcode, encoded)
  return true
end

local function parseRequestedPage(buffer)
  if type(buffer) ~= 'string' or buffer == '' then
    return 1
  end

  local page = buffer:match('^page:(%d+)$')
  return math.max(1, tonumber(page) or 1)
end

local BossTimersExtended = CreatureEvent('BossTimersExtended')
function BossTimersExtended.onExtendedOpcode(player, opcode, buffer)
  if opcode == BossTimers.opcode then
    BossTimers.send(player, parseRequestedPage(buffer))
  end
end
BossTimersExtended:type('extendedopcode')
BossTimersExtended:register()
