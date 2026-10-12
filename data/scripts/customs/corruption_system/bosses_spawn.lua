print(">> Corruption Bosses Loaded")

function notifyPlayers(markPos, markText, sound, extraBroadcast)
  Game.broadcastMessage(extraBroadcast or markText, MESSAGE_EVENT_ADVANCE)

  local players = Game.getPlayers()
  if #players == 0 then return end

  for _, p in ipairs(players) do
    if sound then
      playSoundPlayer(p, sound)
    end
    if markPos and markText then
      p:addMapMark(markPos, 22, markText)
    end
  end
end

function findBossByName(bossName)
  for _, monster in ipairs(Game.getMonsters()) do
    if monster:getName():lower() == bossName:lower() then
      return monster
    end
  end
  return nil
end

function spawnBoss(bossName, bossPos)
  local existingBoss = findBossByName(bossName)
  if existingBoss then
    existingBoss:remove()
  end

  print("Corruption Boss: " .. bossName .. " has appeared!")
  Game.createMonster(bossName, bossPos)
  return true
end

local bosses = {
  {
    id = "gravexonthedevourer",

    schedules = {
      { day = "Monday", time = "12:00:00" },
      { day = "Wednesday", time = "13:00:00" },
      { day = "Friday", time = "20:30:00" },
      { day = "Sunday", time = "11:30:00" },
    },

    bossName = "Gravexon The Devourer",
    bossPos  = Position(32358, 31891, 5),
    markPos  = Position(32358, 31891, 7),
    markText = "Corruption Boss: Gravexon The Devourer",
    broadcast= "Gravexon The Devourer has spawned on Island at north of Thais.",
    sound    = "expedition.ogg",
  },
  {
    id = "kaeldraththefallen",

    schedules = {
      { day = "Monday", time = "18:00:00" },
      { day = "Tuesday", time = "18:00:00" },
      { day = "Thursday", time = "18:00:00" },
      { day = "Saturday", time = "18:00:00" },
    },

    bossName = "Kaeldrath The Fallen",
    bossPos  = Position(33459, 32229, 9),
    markPos  = Position(33459, 32229, 7),
    markText = "Corruption Boss: Kaeldrath The Fallen",
    broadcast= "Kaeldrath The Fallen has spawned on Island at north of Roshamuul.",
    sound    = "expedition.ogg",
  },
  {
    id = "velkorththeplaguebringer",

    schedules = {
      { day = "Monday", time = "12:00:00" },
      { day = "Wednesday", time = "13:00:00" },
      { day = "Friday", time = "20:30:00" },
      { day = "Sunday", time = "11:30:00" },
    },

    bossName = "Velkorth The Plaguebringer",
    bossPos  = Position(32766, 30942, 5),
    markPos  = Position(32766, 30942, 7),
    markText = "Corruption Boss: Velkorth The Plaguebringer",
    broadcast= "Velkorth The Plaguebringer has spawned on Island at north of Yalahar.",
    sound    = "expedition.ogg",
  },
  {
    id = "zorgraththecarrion",

    schedules = {
      { day = "Tuesday", time = "10:00:00" },
      { day = "Wednesday", time = "10:00:00" },
      { day = "Thursday", time = "10:00:00" },
      { day = "Friday", time = "10:00:00" },
    },

    bossName = "Zorgrath The Carrion",
    bossPos  = Position(32495, 32581, 6),
    markPos  = Position(32495, 32581, 7),
    markText = "Corruption Boss: Zorgrath The Carrion",
    broadcast= "Zorgrath The Carrion has spawned on Island at north of Port Hope.",
    sound    = "expedition.ogg",
  },
  {
    id = "velkyrionthefractured",

    schedules = {
      { day = "Monday", time = "15:00:00" },
      { day = "Wednesday", time = "15:00:00" },
      { day = "Saturday", time = "15:00:00" },
      { day = "Sunday", time = "15:00:00" },
    },

    bossName = "Velkyrion The Fractured",
    bossPos  = Position(32247, 33073, 9),
    markPos  = Position(32247, 33073, 7),
    markText = "Corruption Boss: Velkyrion The Fractured",
    broadcast= "Velkyrion The Fractured has spawned on Island at south of Liberty Bay.",
    sound    = "expedition.ogg",
  },
  {
    id = "kraxxisthecorruptor",

    schedules = {
      { day = "Monday", time = "20:00:00" },
      { day = "Wednesday", time = "20:00:00" },
      { day = "Saturday", time = "20:00:00" },
    },

    bossName = "Kraxxis The Corruptor",
    bossPos  = Position(33333, 31400, 11),
    markPos  = Position(33442, 31417, 7),
    markText = "Corruption Boss: Kraxxis The Corruptor",
    broadcast= "Kraxxis The Corruptor has spawned on Island at west of Bounac.",
    sound    = "expedition.ogg",
  },
  {
    id = "kraxxistheavatarofcorruption",

    schedules = {
      { day = "Tuesday", time = "21:00:00" },
      { day = "Friday", time = "21:00:00" },
    },

    bossName = "Kraxxis Avatar of Corruption",
    bossPos  = Position(33330, 31400, 11),
    markPos  = Position(33442, 31417, 7),
    markText = "Corruption Boss: Kraxxis Avatar of Corruption",
    broadcast= "Kraxxis Avatar of Corruption has spawned on Island at west of Bounac.",
    sound    = "expedition.ogg",
  },
  {
    id = "rathmorathebloodtyrant",

    schedules = {
      { day = "Tuesday", time = "20:00:00" },
      { day = "Thursday", time = "20:00:00" },
      { day = "Sunday", time = "20:00:00" },
    },

    bossName = "Rathmora The Blood Tyrant",
    bossPos  = Position(33333, 31514, 12),
    markPos  = Position(33442, 31417, 7),
    markText = "Corruption Boss: Rathmora The Blood Tyrant",
    broadcast= "Rathmora The Blood Tyrant has spawned on Island at west of Bounac.",
    sound    = "expedition.ogg",
  },
  {
    id = "rathmoraascendanttyrant",

    schedules = {
      { day = "Thursday", time = "21:00:00" },
      { day = "Saturday", time = "21:00:00" },
    },

    bossName = "Rathmora Ascendant Tyrant",
    bossPos  = Position(33331, 31514, 12),
    markPos  = Position(33442, 31417, 7),
    markText = "Corruption Boss: Rathmora Ascendant Tyrant",
    broadcast= "Rathmora Ascendant Tyrant has spawned on Island at west of Bounac.",
    sound    = "expedition.ogg",
  },
}

local function createEvent(entry)
  for index, schedule in ipairs(entry.schedules) do
    local ev = GlobalEvent(entry.id .. "_" .. index)

    function ev.onTime()
      if os.date("%A") ~= schedule.day then
        return true
      end

      if entry.multi then
        local spawnedAny = false
        for _, b in ipairs(entry.multi) do
          if spawnBoss(b.name, b.pos) then
            spawnedAny = true
          end
        end

        if spawnedAny then
          notifyPlayers(entry.markPos, entry.markText, entry.sound, entry.broadcast)
        end
      else
        if spawnBoss(entry.bossName, entry.bossPos) then
          notifyPlayers(entry.markPos, entry.markText, entry.sound, entry.broadcast)
        end
      end

      return true
    end

    ev:time(schedule.time)
    ev:register()
  end
end

for _, entry in ipairs(bosses) do
  createEvent(entry)
end